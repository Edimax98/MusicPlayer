//
//  ViewController.swift
//  Music Player
//
//  Created by polat on 19/08/14.
//  Copyright (c) 2014 polat. All rights reserved.
// contact  bpolat@live.com

import UIKit
import AVFoundation
import MediaPlayer
import FBSDKCoreKit
import Alamofire

class PlayerViewController: UIViewController, PopupContentViewController {
    
    var songWasSelected: ((_ song: Song) -> Void)?
    var closeWithSongPlaying: ((_ currentItem: AVPlayerItem?,_ time: CMTime?) -> Void)?
    var closeWithSongPaused: ((_ currentItem: AVPlayerItem?,_ time: CMTime?) -> Void)?
    var closeWithAlbumPlaying: ((_ items: [AVPlayerItem]?,_ currentItemIndex: Int,_ time: CMTime?) -> Void)?
    var closeWithAlbumPaused: ((_ items: [AVPlayerItem]?,_ currentItemIndex: Int,_ time: CMTime?) -> Void)?
    var closeHandler: (() -> Void)?

    weak var playerDelegate: PlayerViewControllerDelegate?
    
    var audioPlayer = AVPlayer()
    var currentAudioPath: URL!
    var currentAudioIndex = 0
    var timer: Timer?
    var audioLength = 0.0
    var albumTracks = [Song]()
    var song: Song?
    var playerItems = [AVPlayerItem]()
    var isAlbum = false
    
    weak var actionHanler: MusicPlayerActionHandler?
    
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var albumArtworkImageView: UIImageView!
    @IBOutlet weak var albumNameLabel: UILabel!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var progressTimerLabel: UILabel!
    @IBOutlet weak var playerProgressSlider: UISlider!
    @IBOutlet weak var totalLengthOfAudioLabel: UILabel!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: self.audioPlayer.currentItem)
    }

    override func remoteControlReceived(with event: UIEvent?) {
        if event!.type == UIEventType.remoteControl {
            switch event!.subtype {
            case UIEventSubtype.remoteControlPlay:
                play(self)
            case UIEventSubtype.remoteControlPause:
                play(self)
            case UIEventSubtype.remoteControlNextTrack:
                next(self)
            case UIEventSubtype.remoteControlPreviousTrack:
                previous(self)
            default:
                print("There is an issue with the control")
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.default
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isAlbum {
            exitButton.setImage(UIImage(named: "back_arrow"), for: .normal)
        }
        
        albumArtworkImageView.layer.borderWidth = 1
        albumArtworkImageView.layer.cornerRadius = 50
        albumArtworkImageView.clipsToBounds = true
        setupRemoteCommandCenter()
       NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(notification:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.audioPlayer.currentItem)
        updateLabels()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }
    
    class func instance() -> PlayerViewController {
        
        let storyboard = UIStoryboard(name: "PlayerView", bundle: nil)
        return storyboard.instantiateInitialViewController() as! PlayerViewController
    }
    
    private func fillPlayerItems(with songs: [Song]) {
        
        for song in songs {
            guard let url = URL(string: song.audioPath) else {
                print("Incorrect url")
                return
            }
            let asset = AVAsset(url: url)
            let item = AVPlayerItem(asset: asset)
            playerItems.append(item)
        }
    }
    
    @objc func playerItemDidReachEnd(notification: NSNotification) {
        playNextAudio()
    }
    
    func sizeForPopup(_ popupController: PopupController, size: CGSize, showingKeyboard: Bool) -> CGSize {
        return CGSize(width: 350, height: 500)
    }
    
    func saveCurrentTrackNumber() {
        UserDefaults.standard.set(currentAudioIndex, forKey: "currentAudioIndex")
        UserDefaults.standard.synchronize()
    }
    
    func retrieveSavedTrackNumber() {
        
        if let currentAudioIndex_ = UserDefaults.standard.object(forKey: "currentAudioIndex") as? Int{
            currentAudioIndex = currentAudioIndex_
        } else {
            currentAudioIndex = 0
        }
    }
    
    func setCurrentAudioPath() {
        
        guard let song = self.song else {
            print("Song is nil")
            return
        }
        
        guard let url = URL(string: song.audioPath) else {
            print("URL is nil")
            return
        }
        
        currentAudioPath = url
    }
    
    func prepareAudio() {
        
        let audioSession = AVAudioSession.sharedInstance()

        do {
            try audioSession.setActive(true)
        } catch let error {
            print("Error in audio session - ", error.localizedDescription)
        }
        
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
        } catch let error {
            print("Error in audio session - ", error.localizedDescription)
        }
        
        audioPlayer.replaceCurrentItem(with: playerItems[currentAudioIndex])
        playerProgressSlider.maximumValue = CFloat(albumTracks[currentAudioIndex].duration)
        playerProgressSlider.minimumValue = 0.0
        playerProgressSlider.value = 0.0
        showTotalSongLength()
        updateLabels()
        progressTimerLabel.text = "00:00"
    }
    
    func playAudio() {
        
        stopTimer()
        prepareAudio()
        audioPlayer.play()
        startTimer()
        updateLabels()
        saveCurrentTrackNumber()
    }
    
    func playNextAudio() {
        
        if currentAudioIndex + 1 > playerItems.count - 1 || currentAudioIndex + 1 > albumTracks.count - 1 {
            currentAudioIndex = 0
        } else {
            currentAudioIndex += 1
        }
        
        playAudio()
        playButton.setImage(#imageLiteral(resourceName: "pause.png"), for: .normal)
        resetTime()
    }
    
    func playPreviousAudio() {
        
        if currentAudioIndex - 1 < 0 {
            currentAudioIndex = (playerItems.count - 1) < 0 ? 0 : (playerItems.count - 1)
        } else {
            currentAudioIndex -= 1
        }
        playAudio()
        resetTime()
    }
    
    func pauseAudioPlayer() {
        
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch let error {
            print(error.localizedDescription)
        }
        playButton.setImage(#imageLiteral(resourceName: "play_track"), for: UIControlState())
        audioPlayer.pause()
    }
    
    func startTimer() {
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(update(_:)), userInfo: nil, repeats: true)
        if let unwrappedTimer = timer {
            unwrappedTimer.fire()
        }
    }
    
    func stopTimer() {
        if let unwrappedTimer = timer {
            unwrappedTimer.invalidate()
        }
    }
    
    private func resetTime() {
        audioPlayer.seek(to: kCMTimeZero)
    }
    
    func secondsToMinutesSeconds(seconds : UInt) -> (minutes: UInt, seconds: UInt) {
        
        let minutes = seconds % 3600 / 60
        let seconds = seconds % 3600 % 60
        
        return (minutes,seconds)
    }
    
    @objc func update(_ timer: Timer?) {
        
        if audioPlayer.rate == 0 {
            return
        }
        
        let seconds = audioPlayer.currentTime().seconds
        let time = secondsToMinutesSeconds(seconds: UInt(seconds))
        
        progressTimerLabel.text = String(format: "%02i:%02i", time.minutes, time.seconds)
        playerProgressSlider.value = CFloat(seconds)
        UserDefaults.standard.set(playerProgressSlider.value , forKey: "playerProgressSliderValue")
    }
    
    func showTotalSongLength() {
        
        let time = secondsToMinutesSeconds(seconds: albumTracks[currentAudioIndex].duration)
        totalLengthOfAudioLabel.text = String(format: "%02i:%02i", time.minutes, time.seconds)
    }
    
    func updateLockScreen(with track: Song?) {
        
        // Define Now Playing Info
        var nowPlayingInfo = [String : Any]()
        if let artist = track?.artistName {
            nowPlayingInfo[MPMediaItemPropertyArtist] = artist
        }
        if let title = track?.name {
            nowPlayingInfo[MPMediaItemPropertyTitle] = title
        }
        if let image = track?.image {
            nowPlayingInfo[MPMediaItemPropertyArtwork] =
                MPMediaItemArtwork(boundsSize: image.size) { size in
                    return image
            }
        }
       // nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = playerItems[currentAudioIndex].currentTime().seconds
       // nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = playerItems[currentAudioIndex].asset.duration.seconds
       // nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = audioPlayer.rate
        // Set the metadata
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Add handler for Play Command
        commandCenter.playCommand.addTarget { event in
            return .success
        }
        
        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget { event in
            return .success
        }
        
        // Add handler for Next Command
        commandCenter.nextTrackCommand.addTarget { event in
            return .success
        }
        
        // Add handler for Previous Command
        commandCenter.previousTrackCommand.addTarget { event in
            return .success
        }
    }
    
    func updateLabels() {
        //updateLockScreen(with: albumTracks[currentAudioIndex])
        albumNameLabel.text = albumTracks[currentAudioIndex].albumName
        songNameLabel.text = albumTracks[currentAudioIndex].name
        albumArtworkImageView.image = albumTracks[currentAudioIndex].image
    }
    
    
    @IBAction func play(_ sender : AnyObject) {
        
        //        let alert = UIAlertController(title: "Trial", message: nil, preferredStyle: .alert)
        //        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        //        alert.addAction(okAction)
        //        self.present(alert, animated: true) {
        
        //            FBSDKAppEvents.logEvent("Trial has started", parameters: ["trial_subscription": FBSDKAppEventParameterNameContentType,
        //                                                                      "id": FBSDKAppEventParameterNameContentID,
        //                                                                      "USD": FBSDKAppEventParameterNameCurrency])
        //    FBSDKAppEvents.logPurchase(0.0, currency: "USD", parameters: ["trial_subscription": FBSDKAppEventParameterNameContentType,
        // "id": FBSDKAppEventParameterNameContentID])
        //  FBSDKAppEvents.logPurchase(0.0, currency: "USD", parameters: [FBSDKAppEventParameterNameContentType : "trial",
        //       FBSDKAppEventParameterNameContentID : "id"])
        //      }
        
        let play = UIImage(named: "play_track")
        let pause = UIImage(named: "pause")

        if audioPlayer.rate > 0 {
            pauseAudioPlayer()
            playerDelegate?.didPressPlayButton()
            audioPlayer.rate > 0 ? playButton.setImage(pause, for: UIControlState()) : playButton.setImage(play , for: UIControlState())
        } else {
            playAudio()
            playerDelegate?.didPressPlayButton()
            audioPlayer.rate > 0 ? playButton.setImage(pause, for: UIControlState()) : playButton.setImage(play , for: UIControlState())
        }
    }
    
    @IBAction func next(_ sender : AnyObject) {
        playNextAudio()
    }
    
    @IBAction func previous(_ sender : AnyObject) {
        playPreviousAudio()
    }
    
    @IBAction func changeAudioLocationSlider(_ sender : UISlider) {
        
        let seconds = Double(sender.value)
        let targetTime = CMTime(seconds: seconds, preferredTimescale: 1000)
        audioPlayer.seek(to: targetTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
    }
    
    @IBAction func hidePlayerButtonPressed(_ sender: Any) {
    
        if audioPlayer.rate == 0 {
            if isAlbum {
                closeWithAlbumPaused?(playerItems, currentAudioIndex, playerItems[currentAudioIndex].currentTime())
            } else {
                closeWithSongPaused?(playerItems[currentAudioIndex], playerItems[currentAudioIndex].currentTime())
            }
            return
        }
    
        if isAlbum {
            closeWithAlbumPlaying?(playerItems, currentAudioIndex, audioPlayer.currentTime())
        } else {
            closeWithSongPlaying?(playerItems[currentAudioIndex], audioPlayer.currentTime())
        }
    }
    
    fileprivate func setIndex(for songToFindIndex: Song) {
        
        let index = albumTracks.index { (song) -> Bool in
            if songToFindIndex == song {
                return true
            }
            return false
        }
        
        guard let songIndex = index else {
            print("Found index is nil")
            return
        }
        currentAudioIndex = Int(songIndex)
    }
}

// MARK: - SongsActionHandler
extension PlayerViewController: SongsActionHandler {
    
    func musicWasSelected(_ song: Song) {
        songWasSelected?(song)
        updateLockScreen(with: song)
        if !albumTracks.isEmpty {
            setIndex(for: song)
        } else {
            albumTracks.append(song)
            fillPlayerItems(with: [song])
        }
    }
}

// MARK: - LandingPageViewOutputMultipleValues
extension PlayerViewController: LandingPageViewOutputMultipleValues {
    
    func sendSongs(_ songs: [Song]) {
        self.albumTracks = songs
        fillPlayerItems(with: songs)
        isAlbum = true
    }
}





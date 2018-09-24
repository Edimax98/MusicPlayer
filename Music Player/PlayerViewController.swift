//
//  ViewController.swift
//  Music Player
//
//  Created by polat on 19/08/14.
//  Copyright (c) 2014 polat. All rights reserved.
// contact  bpolat@live.com

// Build 3 - July 1 2015 - Please refer git history for full changes
// Build 4 - Oct 24 2015 - Please refer git history for full changes

//Build 5 - Dec 14 - 2015 Adding shuffle - repeat


import UIKit
import AVFoundation
import MediaPlayer
import FBSDKCoreKit
import Alamofire

class PlayerViewController: UIViewController, PopupContentViewController {
    
    var closeHandler: (() -> Void)?
    
    //Choose background here. Between 1 - 7
    let selectedBackground = 2
    
    var audioPlayer = AVPlayer()
    var currentAudioPath:URL!
    var audioList:NSArray!
    var currentAudioIndex = 0
    var timer:Timer!
    var audioLength = 0.0
    var toggle = true
    var effectToggle = true
    var totalLengthOfAudio = ""
    var finalImage:UIImage!
    var shuffleArray = [Int]()
    var albumTracks = [Song]()
    var song: Song?
    var playerItems = [AVPlayerItem]()
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet var songNo : UILabel!
    @IBOutlet var lineView : UIView!
    @IBOutlet weak var albumArtworkImageView: UIImageView!
    @IBOutlet weak var albumNameLabel: UILabel!
    @IBOutlet var songNameLabel: UILabel!
    @IBOutlet var songNameLabelPlaceHolder : UILabel!
    @IBOutlet var progressTimerLabel : UILabel!
    @IBOutlet var playerProgressSlider : UISlider!
    @IBOutlet var totalLengthOfAudioLabel : UILabel!
    @IBOutlet var previousButton : UIButton!
    @IBOutlet var playButton : UIButton!
    @IBOutlet var nextButton : UIButton!
    @IBOutlet var listButton : UIButton!
    @IBOutlet var enhancer : UIView!
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.default
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(notification:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.audioPlayer.currentItem)
        albumArtworkImageView.layer.cornerRadius = 120 / 2 //albumArtworkImageView.frame.width / 2
        albumArtworkImageView.layer.masksToBounds = true
        fillPlayerItems(with: albumTracks)
        prepareAudio()
        updateLabels()
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
        resetTime()
        playNextAudio()
    }
    
    func sizeForPopup(_ popupController: PopupController, size: CGSize, showingKeyboard: Bool) -> CGSize {
        return CGSize(width: 350, height: 500)
    }
    
    func saveCurrentTrackNumber() {
        
        UserDefaults.standard.set(currentAudioIndex, forKey: "currentAudioIndex")
        UserDefaults.standard.synchronize()
    }
    
    class func instance() -> PlayerViewController {
        let storyboard = UIStoryboard(name: "PlayerView", bundle: nil)
        return storyboard.instantiateInitialViewController() as! PlayerViewController
    }
    
    func retrieveSavedTrackNumber() {
        
        if let currentAudioIndex_ = UserDefaults.standard.object(forKey: "currentAudioIndex") as? Int{
            currentAudioIndex = currentAudioIndex_
        } else {
            currentAudioIndex = 0
        }
    }
    
    //Sets audio file URL
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
    
    // Prepare audio for playing
    func prepareAudio() {
        
        do {
            //keep alive audio at background
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch _ {
        }

        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch _ {
        }

        UIApplication.shared.beginReceivingRemoteControlEvents()
        audioPlayer.replaceCurrentItem(with: playerItems.first)
        playerProgressSlider.maximumValue = CFloat(albumTracks[currentAudioIndex].duration)
        playerProgressSlider.minimumValue = 0.0
        playerProgressSlider.value = 0.0
        showTotalSongLength()
        updateLabels()
        progressTimerLabel.text = "00:00"
    }
    
    //MARK:- Player Controls Methods
    func  playAudio() {
        audioPlayer.replaceCurrentItem(with: playerItems[currentAudioIndex])
        audioPlayer.play()
        startTimer()
        updateLabels()
        saveCurrentTrackNumber()
    }
    
    func playNextAudio() {
        
        if currentAudioIndex + 1 > playerItems.count - 1 {
            currentAudioIndex = 0
        } else {
            currentAudioIndex += 1
        }
        
        if audioPlayer.rate > 0 {
            prepareAudio()
            playAudio()
        } else {
            prepareAudio()
        }
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
        audioPlayer.pause()
    }
    
    func startTimer() {
    
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(update(_:)), userInfo: nil, repeats: true)
            timer.fire()
        }
    }
    
    func stopTimer() {
        timer.invalidate()
    }
    
    private func resetTime() {
        audioPlayer.seek(to: kCMTimeZero)
    }
    
    @objc func update(_ timer: Timer) {
        
        if audioPlayer.rate == 0 {
            return
        }
        
        let seconds = audioPlayer.currentTime().seconds
        let time = secondsToMinutesSeconds(seconds: UInt(seconds))
        
        progressTimerLabel.text = String(format:"%02i:%02i", time.minutes, time.seconds)
        playerProgressSlider.value = CFloat(seconds)
        UserDefaults.standard.set(playerProgressSlider.value , forKey: "playerProgressSliderValue")
    }

    func secondsToMinutesSeconds (seconds : UInt) -> (minutes: UInt, seconds: UInt) {
        
        let minutes = seconds % 3600 / 60
        let seconds = seconds % 3600 % 60
        
        return (minutes,seconds)
    }
    
    func showTotalSongLength() {
        
        let time = secondsToMinutesSeconds(seconds: albumTracks[currentAudioIndex].duration)
        totalLengthOfAudioLabel.text = String(format:"%02i:%02i", time.minutes, time.seconds)
    }
    
    func updateLabels() {
        
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
            audioPlayer.rate > 0 ? "\(playButton.setImage( pause, for: UIControlState()))" : "\(playButton.setImage(play , for: UIControlState()))"
        } else {
            playAudio()
            audioPlayer.rate > 0 ? "\(playButton.setImage( pause, for: UIControlState()))" : "\(playButton.setImage(play , for: UIControlState()))"
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
    
    @IBAction func userTapped(_ sender : UITapGestureRecognizer) {
        play(self)
    }
    
    @IBAction func userSwipeLeft(_ sender : UISwipeGestureRecognizer) {
        next(self)
    }
    
    @IBAction func userSwipeRight(_ sender : UISwipeGestureRecognizer) {
        previous(self)
    }
    
    @IBAction func hidePlayerButtonPressed(_ sender: Any) {
        closeHandler?()
    }
}

// MARK: - SongsActionHandler
extension PlayerViewController: SongsActionHandler {
    
    func musicWasSelected(_ song: Song) {
        albumTracks.append(song)
        let newItem = AVPlayerItem(url: URL(string: song.audioPath)!)
        playerItems.append(newItem)
    }
}

// MARK: - LandingPageViewOutputMultipleValues
extension PlayerViewController: LandingPageViewOutputMultipleValues {
    
    func sendSongs(_ songs: [Song]) {
        self.albumTracks = songs
        fillPlayerItems(with: songs)
    }
}





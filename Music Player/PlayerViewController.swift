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

class PlayerViewController: UIViewController, UITableViewDataSource, AVAudioPlayerDelegate {
    
    //Choose background here. Between 1 - 7
    let selectedBackground = 2
    
    var audioPlayer: AVPlayer! = nil
    //var queuePlayer = AVQueuePlayer()
    var currentAudio = ""
    var currentAudioPath:URL!
    var audioList:NSArray!
    var currentAudioIndex = 0
    var timer:Timer!
    var audioLength = 0.0
    var toggle = true
    var effectToggle = true
    var totalLengthOfAudio = ""
    var finalImage:UIImage!
    var isTableViewOnscreen = false
    var shuffleState = false
    var repeatState = false
    var shuffleArray = [Int]()
    var song: Song?
    var albumTracks = [Song]()
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet var songNo : UILabel!
    @IBOutlet var lineView : UIView!
    @IBOutlet weak var albumArtworkImageView: UIImageView!
    @IBOutlet weak var artistNameLabel: UILabel!
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
    @IBOutlet var tableView : UITableView!
    @IBOutlet var blurImageView : UIImageView!
    @IBOutlet var enhancer : UIView!
    @IBOutlet var tableViewContainer : UIView!
    
    @IBOutlet weak var shuffleButton: UIButton!
    @IBOutlet weak var repeatButton: UIButton!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var tableViewContainerTopConstrain: NSLayoutConstraint!
    
    //MARK:- Lockscreen Media Control
    // This shows media info on lock screen - used currently and perform controls
    func showMediaInfo() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyArtist : song!.artistName,  MPMediaItemPropertyTitle : song!.name]
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
    
    // Table View Part of the code. Displays Song name and Artist Name
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell  {
        //        var songNameDict = NSDictionary()
        //        songNameDict = audioList.object(at: (indexPath as NSIndexPath).row) as! NSDictionary
        //        let songName = songNameDict.value(forKey: "songName") as! String
        //
        //        var albumNameDict = NSDictionary()
        //        albumNameDict = audioList.object(at: (indexPath as NSIndexPath).row) as! NSDictionary
        //        let albumName = albumNameDict.value(forKey: "albumName") as! String
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        //        cell.textLabel?.font = UIFont(name: "BodoniSvtyTwoITCTT-BookIta", size: 25.0)
        //        cell.textLabel?.textColor = UIColor.white
        //        cell.textLabel?.text = songName
        //
        //        cell.detailTextLabel?.font = UIFont(name: "BodoniSvtyTwoITCTT-Book", size: 16.0)
        //        cell.detailTextLabel?.textColor = UIColor.white
        //        cell.detailTextLabel?.text = albumName
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54.0
    }
    
    func tableView(_ tableView: UITableView,willDisplay cell: UITableViewCell,forRowAt indexPath: IndexPath) {
        
        tableView.backgroundColor = UIColor.clear
        let backgroundView = UIView(frame: CGRect.zero)
        backgroundView.backgroundColor = UIColor.clear
        cell.backgroundView = backgroundView
        cell.backgroundColor = UIColor.clear
    }
    
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        animateTableViewToOffScreen()
        currentAudioIndex = (indexPath as NSIndexPath).row
        prepareAudio()
        playAudio()
        effectToggle = !effectToggle
        let showList = UIImage(named: "list")
        let removeList = UIImage(named: "listS")
        effectToggle ? "\(listButton.setImage(showList, for: UIControlState()))" : "\(listButton.setImage(removeList , for: UIControlState()))"
        let play = UIImage(named: "play")
        let pause = UIImage(named: "pause")
        audioPlayer.rate > 0 ? "\(playButton.setImage(pause, for: UIControlState()))" : "\(playButton.setImage(play , for: UIControlState()))"
        
        blurView.isHidden = true
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.default
    }
    
    override var prefersStatusBarHidden : Bool {
        if isTableViewOnscreen {
            return true
        } else {
            return false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundImageView.image = UIImage(named: "background\(selectedBackground)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableViewContainerTopConstrain.constant = 1000.0
        self.tableViewContainer.layoutIfNeeded()
        blurView.isHidden = true
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        albumArtworkImageView.setRounded()
    }

    func setRepeatAndShuffle() {
        
        shuffleState = UserDefaults.standard.bool(forKey: "shuffleState")
        repeatState = UserDefaults.standard.bool(forKey: "repeatState")
        
        if shuffleState == true {
            shuffleButton.isSelected = true
        } else {
            shuffleButton.isSelected = false
        }
        
        if repeatState == true {
            repeatButton.isSelected = true
        } else {
            repeatButton.isSelected = false
        }
    }
    
    // MARK:- AVAudioPlayer Delegate's Callback method
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool){
        if flag == true {
            
            if shuffleState == false && repeatState == false {
                // do nothing
                playButton.setImage( UIImage(named: "play"), for: UIControlState())
                return
                
            } else if shuffleState == false && repeatState == true {
                //repeat same song
                prepareAudio()
                playAudio()
                
            } else if shuffleState == true && repeatState == false {
                //shuffle songs but do not repeat at the end
                //Shuffle Logic : Create an array and put current song into the array then when next song come randomly choose song from available song and check against the array it is in the array try until you find one if the array and number of songs are same then stop playing as all songs are already played.
                shuffleArray.append(currentAudioIndex)
                if shuffleArray.count >= audioList.count {
                    playButton.setImage(UIImage(named: "play"), for: UIControlState())
                    return
                }
                
                var randomIndex = 0
                var newIndex = false
                while newIndex == false {
                    randomIndex = Int(arc4random_uniform(UInt32(audioList.count)))
                    if shuffleArray.contains(randomIndex) {
                        newIndex = false
                    } else {
                        newIndex = true
                    }
                }
                currentAudioIndex = randomIndex
                prepareAudio()
                playAudio()
                
            } else if shuffleState == true && repeatState == true {
                //shuffle song endlessly
                shuffleArray.append(currentAudioIndex)
                if shuffleArray.count >= audioList.count {
                    shuffleArray.removeAll()
                }
                
                var randomIndex = 0
                var newIndex = false
                while newIndex == false {
                    randomIndex =  Int(arc4random_uniform(UInt32(audioList.count)))
                    if shuffleArray.contains(randomIndex) {
                        newIndex = false
                    } else {
                        newIndex = true
                    }
                }
                
                currentAudioIndex = randomIndex
                prepareAudio()
                playAudio()
            }
        }
    }
    
    func addAllSongsToQueuePlayer() {
        
//        for song in albumTracks {
//            guard let url = URL(string: song.audioPath) else {
//                print("Incorrect url")
//                return
//            }
//            let asset = AVAsset(url: url)
//            let item = AVPlayerItem(asset: asset)
//            audioPlayer.insert(item, after: queuePlayer.items().last)
//        }
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
        
        setCurrentAudioPath()
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
        let playerItem = AVPlayerItem(url: currentAudioPath)
        audioPlayer = AVPlayer(playerItem: playerItem)
        //addAllSongsToQueuePlayer()
        playerProgressSlider.maximumValue = CFloat(song!.duration)
        playerProgressSlider.minimumValue = 0.0
        playerProgressSlider.value = 0.0
        showTotalSongLength()
        updateLabels()
        progressTimerLabel.text = "00:00"
    }
    
    //MARK:- Player Controls Methods
    func  playAudio() {
        audioPlayer.play()
        startTimer()
        updateLabels()
        saveCurrentTrackNumber()
        showMediaInfo()
    }
    
    func playNextAudio(){
        
        currentAudioIndex += 1
        if currentAudioIndex > audioList.count - 1{
            currentAudioIndex -= 1
            return
        }
        
        if audioPlayer.rate > 0 {
            prepareAudio()
            playAudio()
        } else {
            prepareAudio()
        }
    }
    
    func playPreviousAudio(){
        currentAudioIndex -= 1
        if currentAudioIndex<0{
            currentAudioIndex += 1
            return
        }
        if audioPlayer.rate > 0 {
            prepareAudio()
            playAudio()
        }else{
            prepareAudio()
        }
    }
    
    func pauseAudioPlayer(){
        audioPlayer.pause()
    }
    
    func startTimer() {
    
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(update(_:)), userInfo: nil,repeats: true)
            timer.fire()
        }
    }
    
    func stopTimer() {
        timer.invalidate()
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
    
    func retrievePlayerProgressSliderValue() {
        
        let playerProgressSliderValue =  UserDefaults.standard.float(forKey: "playerProgressSliderValue")
        if playerProgressSliderValue != 0 {
            
            playerProgressSlider.value  = playerProgressSliderValue
            let seconds = Double(playerProgressSlider.value)
            let targetTime = CMTime(seconds: seconds, preferredTimescale: 1000)
            audioPlayer.seek(to: targetTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
            
            let currentTime = audioPlayer.currentTime().seconds
            let time = secondsToMinutesSeconds(seconds: song!.duration)
            progressTimerLabel.text = String(format:"%02i:%02i", time.minutes, time.seconds)
            playerProgressSlider.value = CFloat(currentTime)
            
        } else {
            playerProgressSlider.value = 0.0
            let targetTime = CMTime()
            audioPlayer.seek(to: targetTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
            progressTimerLabel.text = "00:00:00"
        }
    }
    
    func secondsToMinutesSeconds (seconds : UInt) -> (minutes: UInt, seconds: UInt) {
        
        let minutes = seconds % 3600 / 60
        let seconds = seconds % 3600 % 60
        
        return (minutes,seconds)
    }
    
    func showTotalSongLength() {
        
        let time = secondsToMinutesSeconds(seconds: song!.duration)
        totalLengthOfAudioLabel.text = String(format:"%02i:%02i", time.minutes, time.seconds)
    }
    
    func updateLabels() {
        
        guard let song = self.song else {
            print("Song is nil")
            return
        }
        
        artistNameLabel.text = song.artistName
        albumNameLabel.text = song.albumName
        songNameLabel.text = song.name
        albumArtworkImageView.image = song.image
    }
    
    //creates animation and push table view to screen
    func animateTableViewToScreen() {
        self.blurView.isHidden = false
        UIView.animate(withDuration: 0.15, delay: 0.01, options:
            UIViewAnimationOptions.curveEaseIn, animations: {
                self.tableViewContainerTopConstrain.constant = 0.0
                self.tableViewContainer.layoutIfNeeded()
        }, completion: { (bool) in
        })
    }
    
    func animateTableViewToOffScreen() {
        isTableViewOnscreen = false
        setNeedsStatusBarAppearanceUpdate()
        self.tableViewContainerTopConstrain.constant = 1000.0
        
        UIView.animate(withDuration: 0.20, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.tableViewContainer.layoutIfNeeded()
        }, completion: { (value: Bool) in
            self.blurView.isHidden = true
        })
    }
    
    func assingSliderUI () {
        let minImage = UIImage(named: "slider-track-fill")
        let maxImage = UIImage(named: "slider-track")
        let thumb = UIImage(named: "thumb")
        
        playerProgressSlider.setMinimumTrackImage(minImage, for: UIControlState())
        playerProgressSlider.setMaximumTrackImage(maxImage, for: UIControlState())
        playerProgressSlider.setThumbImage(thumb, for: UIControlState())
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
        
        if shuffleState == true {
            shuffleArray.removeAll()
        }
        
        let play = UIImage(named: "play")
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
    
    @IBAction func userSwipeUp(_ sender : UISwipeGestureRecognizer) {
        presentListTableView(self)
    }
    
    @IBAction func shuffleButtonTapped(_ sender: UIButton) {
        
        shuffleArray.removeAll()
        if sender.isSelected == true {
            sender.isSelected = false
            shuffleState = false
            UserDefaults.standard.set(false, forKey: "shuffleState")
        } else {
            sender.isSelected = true
            shuffleState = true
            UserDefaults.standard.set(true, forKey: "shuffleState")
        }
    }
    
    @IBAction func repeatButtonTapped(_ sender: UIButton) {
        
        if sender.isSelected == true {
            sender.isSelected = false
            repeatState = false
            UserDefaults.standard.set(false, forKey: "repeatState")
        } else {
            sender.isSelected = true
            repeatState = true
            UserDefaults.standard.set(true, forKey: "repeatState")
        }
    }
    
    @IBAction func presentListTableView(_ sender: AnyObject) {
        
        if effectToggle {
            isTableViewOnscreen = true
            setNeedsStatusBarAppearanceUpdate()
            self.animateTableViewToScreen()
        } else {
            self.animateTableViewToOffScreen()
        }
        effectToggle = !effectToggle
        let showList = UIImage(named: "list")
        let removeList = UIImage(named: "listS")
        effectToggle ? "\(listButton.setImage(showList, for: UIControlState()))" : "\(listButton.setImage(removeList, for: UIControlState()))"
    }
}

// MARK: - LandingPageViewOutput
extension PlayerViewController: LandingPageViewOutputSingleValue {
    
    func sendSong(_ song: Song) {
        
        self.song = song
        self.songNameLabel.text = song.name
        self.artistNameLabel.text = song.artistName
        
        prepareAudio()
        updateLabels()
        assingSliderUI()
        setRepeatAndShuffle()
    }
}

// MARK: - LandingPageViewOutputMultipleValues
extension PlayerViewController: LandingPageViewOutputMultipleValues {
    
    func sendSongs(_ songs: [Song]) {
        self.albumTracks = songs
        prepareAudio()
        updateLabels()
        assingSliderUI()
        setRepeatAndShuffle()
    }
}





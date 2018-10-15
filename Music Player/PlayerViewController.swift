//
//  ViewController.swift
//  Music Player
//
//  Created by polat on 19/08/14.
//  Copyright (c) 2014 polat. All rights reserved.
// contact  bpolat@live.com

import UIKit
import KDEAudioPlayer

class PlayerViewController: UIViewController {
    
    var songWasSelected: ((_ song: Song) -> Void)?
    var closeHandler: (() -> Void)?

    weak var playerDelegate: PlayerViewControllerDelegate?
    
    private(set) var song: Song?
    private var isAlbum = false
    
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
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
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isAlbum {
            exitButton.setImage(UIImage(named: "back_arrow"), for: .normal)
        }
        
        playButton.setImage(UIImage(named: "pause"), for: .selected)
        activityIndicator.isHidden = true
        albumArtworkImageView.layer.borderWidth = 1
        albumArtworkImageView.layer.cornerRadius = albumArtworkImageView.frame.width / 2
        albumArtworkImageView.clipsToBounds = true
        prepareAudio()
    }
    
    class func instance() -> PlayerViewController {
        
        let storyboard = UIStoryboard(name: "PlayerView", bundle: nil)
        return storyboard.instantiateInitialViewController() as! PlayerViewController
    }
    
    fileprivate func prepareAudio() {
    
        guard let unwrappedSong = song else { print("Song is nil"); return }
        
        playerProgressSlider.maximumValue = CFloat(unwrappedSong.duration)
        playerProgressSlider.minimumValue = 0.0
        playerProgressSlider.value = 0.0
        updateLabels()
    }
    
    fileprivate func secondsToMinutesSeconds(seconds: UInt) -> (minutes: UInt, seconds: UInt) {
        
        let minutes = seconds % 3600 / 60
        let seconds = seconds % 3600 % 60
        
        return (minutes,seconds)
    }
    
    fileprivate func showTotalSongLength() {
        
        guard let unwrappedSong = song else { print("Song is nil"); return }
        
        let time = secondsToMinutesSeconds(seconds: unwrappedSong.duration)
        totalLengthOfAudioLabel.text = String(format: "%02i:%02i", time.minutes, time.seconds)
    }
    
    fileprivate func updateLabels() {
        
        guard let unwrappedSong = song else { print("Song is nil"); return }

        showTotalSongLength()
        albumNameLabel.text = unwrappedSong.albumName
        songNameLabel.text = unwrappedSong.name
        albumArtworkImageView.image = unwrappedSong.image
    }
	
	fileprivate func resetSlider() {
		progressTimerLabel.text = "00:00"
		playerProgressSlider.setValue(0, animated: true)
	}

    @IBAction func play(_ sender: AnyObject) {
        playButton.isSelected = !playButton.isSelected
        playerDelegate?.didPressPlayButton()
    }
    
    @IBAction func next(_ sender : AnyObject) {
		playerDelegate?.didPressNextButton { [weak self] newSong in
			self?.song = newSong
			self?.resetSlider()
			self?.updateLabels()
		}
    }
    
    @IBAction func previous(_ sender : AnyObject) {
		playerDelegate?.didPressPreviousButton { [weak self] newSong in
			self?.song = newSong
			self?.resetSlider()
			self?.updateLabels()
		}
    }
    
    @IBAction func changeAudioLocationSlider(_ sender : UISlider) {
        let targetTime = TimeInterval(sender.value)
        playerDelegate?.didChangeTime(to: targetTime)
    }
    
    @IBAction func hidePlayerButtonPressed(_ sender: Any) {
        closeHandler?()
    }
    
    @IBAction func volumeSliderValueChanged(_ sender: Any) {
        guard let slider = sender as? UISlider else { return }
        playerDelegate?.didChangeVolume(to: slider.value)
    }
}

// MARK: - AudioPlayerDelegate
extension PlayerViewController: AudioPlayerDelegate {
    
    func audioPlayer(_ audioPlayer: AudioPlayer, didLoad range: TimeRange, for item: AudioItem) {
        if audioPlayer.state == .buffering || audioPlayer.state == .waitingForConnection {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
        } else {
            activityIndicator.isHidden = true
            activityIndicator.stopAnimating()
        }
    }
    
    func audioPlayer(_ audioPlayer: AudioPlayer, didUpdateProgressionTo time: TimeInterval, percentageRead: Float) {
        volumeSlider.setValue(audioPlayer.volume, animated: true)
        playerProgressSlider.setValue(Float(time).rounded(), animated: true)
        let secondsAndMinutes = secondsToMinutesSeconds(seconds: UInt(time))
        progressTimerLabel.text = String(format: "%02i:%02i", secondsAndMinutes.minutes, secondsAndMinutes.seconds)
    }
}

// MARK: - SongsActionHandler
extension PlayerViewController: SongActionHandler {
    
    func musicWasSelected(_ song: Song) {
        songWasSelected?(song)
        self.song = song
    }
}

// MARK: - LandingPageViewOutputMultipleValues
extension PlayerViewController: LandingPageViewOutputMultipleValues {
    
    func sendSongs(_ songs: [Song]) {
        isAlbum = true
    }
}

// MARK: - PopupController
extension PlayerViewController: PopupContentViewController {
    
    func sizeForPopup(_ popupController: PopupController, size: CGSize, showingKeyboard: Bool) -> CGSize {
        
        let margin = UIScreen.main.bounds.height * 0.1
        if UIScreen.main.bounds.height > 700 {
            return CGSize(width: self.view.frame.width - 20, height: self.view.frame.height - margin * 1.5)
        }
        return CGSize(width: self.view.frame.width - 20, height: self.view.frame.height - margin + 20)
    }
}



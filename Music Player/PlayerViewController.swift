//
//  ViewController.swift
//  Music Player
//
//  Created by polat on 19/08/14.
//  Copyright (c) 2014 polat. All rights reserved.
// contact  bpolat@live.com

import UIKit
import KDEAudioPlayer
import MediaPlayer

class PlayerViewController: UIViewController {
    
    var closeHandler: (() -> Void)?
    weak var playerDelegate: PlayerViewControllerDelegate?
    
    fileprivate var song: Song?
    private var isAlbum = false
    private var isTimeEditing = false
    
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
    @IBOutlet weak var contanerForVolumeSlider: UIView!
    
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
        playerProgressSlider.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: .valueChanged)
        setupVoulumeSlider()
    }
    
    fileprivate func setupVoulumeSlider() {
        
        contanerForVolumeSlider.backgroundColor = UIColor.clear
        let myVolumeView = MPVolumeView(frame: CGRect(x: 0, y: 6.125, width: contanerForVolumeSlider.bounds.width,
                                                                        height: contanerForVolumeSlider.bounds.height))
        myVolumeView.showsRouteButton = false
        myVolumeView.autoresizingMask = .flexibleWidth
        
        let temp = myVolumeView.subviews
        for current in temp {
            if current.isKind(of: UISlider.self) {
                let tempSlider = current as! UISlider
                tempSlider.minimumTrackTintColor = .white
                tempSlider.maximumTrackTintColor = UIColor(red: 82 / 255, green: 51 / 255, blue: 138 / 255, alpha: 1)
            }
        }
        contanerForVolumeSlider.addSubview(myVolumeView)
    }
    
    fileprivate func prepareAudio() {
    
        guard let unwrappedSong = self.song else { print("Song is nil"); return }
        
        isTimeEditing = false
        playerProgressSlider.maximumValue = CFloat(unwrappedSong.duration)
        playerProgressSlider.minimumValue = 0.0
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
    
    @objc func onSliderValChanged(slider: UISlider, event: UIEvent) {
        
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began:
                isTimeEditing = true
            case .moved:
                isTimeEditing = true
            case .ended:
                isTimeEditing = false
            default:
                break
            }
        }
        let targetTime = TimeInterval(slider.value)
        self.playerDelegate?.didChangeTime(to: targetTime)
    }
    
    @IBAction func hidePlayerButtonPressed(_ sender: Any) {
        closeHandler?()
    }
}

// MARK: - SongReceiver
extension PlayerViewController: SongReceiver {
    
    func receive(model: Song) {
        if self.song != model {
            self.song = model
            resetSlider()
            prepareAudio()
        }
    }
}

// MARK: - AlbumReciever
extension PlayerViewController: AlbumReceiver {
    
    func receive(model: Album) {
        isAlbum = true
    }
}

// MARK: - AudioPlayerDelegate
extension PlayerViewController: AudioPlayerDelegate {
    
    func audioPlayer(_ audioPlayer: AudioPlayer, didChangeStateFrom from: AudioPlayerState, to state: AudioPlayerState) {
        
        if state == .paused || state == .stopped {
            playButton.isSelected = false
        }
        
        if state == .playing || state == .buffering {
            playButton.isSelected = true
        }
    }
    
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
        
        if !isTimeEditing {
            playerProgressSlider.setValue(Float(time).rounded(), animated: false)
        }
        let secondsAndMinutes = secondsToMinutesSeconds(seconds: UInt(time))
        progressTimerLabel.text = String(format: "%02i:%02i", secondsAndMinutes.minutes, secondsAndMinutes.seconds)
        if percentageRead.rounded() == 100 {
            resetSlider()
        }
    }
}

// MARK: - PopupController
extension PlayerViewController: PopupContentViewController {
    
    func sizeForPopup(_ popupController: PopupController, size: CGSize, showingKeyboard: Bool) -> CGSize {
        
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        let marginForBigScreens = UIScreen.main.bounds.height * 0.125 * 2
        let marginForSmallScreens = UIScreen.main.bounds.height * 0.05 * 2
        
        if screenHeight > 700 {
            return CGSize(width: screenWidth - 30, height: screenHeight - marginForBigScreens)
        }
        return CGSize(width: screenWidth - 20, height: screenHeight - marginForSmallScreens)
    }
}



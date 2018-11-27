//
//  MusicListViewController.swift
//  Music Player
//
//  Created by Даниил on 15/10/2018.
//  Copyright © 2018 polat. All rights reserved.
//

import UIKit
import KDEAudioPlayer

class MusicListViewController: UIViewController, PopupContentViewController {
    
    @IBOutlet weak var albumNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var musicTableView: UITableView!
    
    var closeHandler: (() -> Void)?
    var wasShownHandler: (() -> Void)?
    var shouldOfferSubscription = false
    let mediator = Mediator()
    fileprivate var album: Album?
    fileprivate let dataSource = SongsDataSource()
    weak var playerDelegate: PlayerViewControllerDelegate?
    weak var audioPlayerDelegate: AudioPlayerDelegate?
    
    deinit {
        print("deinited ", self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        musicTableView.dataSource = dataSource
        musicTableView.delegate = self
        musicTableView.register(UINib(nibName: "TrackCell", bundle: nil), forCellReuseIdentifier: TrackCell.identifier)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        wasShownHandler?()
    }
    
    func showSubOffer() {
        let subOfferVc = SubscriptionInfoViewController.controllerInStoryboard(UIStoryboard(name: "SubscriptionInfoViewController", bundle: nil), identifier: "SubscriptionInfoViewController")
        self.present(subOfferVc, animated: true, completion: nil)
    }
    
    private func fillLabels() {
        
        guard let album = self.album else { print("Album is nil"); return }
        artistNameLabel.text = album.artistName
        albumNameLabel.text = album.name
    }
    
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
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        closeHandler?()
    }
}

// MARK: - UITableViewDelegate
extension MusicListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let song = dataSource.getSongs()[indexPath.row]
        mediator.send(song: song)
    }
}

extension MusicListViewController: AlbumReceiver {
    
    func receive(model: Album) {
        dataSource.setSongs(model.songs)
        self.album = model
        fillLabels()
        musicTableView.reloadData()
    }
}

extension MusicListViewController: AudioPlayerDelegate {
    
    func audioPlayer(_ audioPlayer: AudioPlayer, didUpdateProgressionTo time: TimeInterval, percentageRead: Float) {
        audioPlayerDelegate?.audioPlayer(audioPlayer, didUpdateProgressionTo: time, percentageRead: percentageRead)
    }
}

extension MusicListViewController: PlayerViewControllerDelegate {
    
    func didChangeVolume(to newVolume: Float) {
        playerDelegate?.didChangeVolume(to: newVolume)
    }
    
    func didPressPreviousButton(completion: @escaping (Song) -> Void) {
        playerDelegate?.didPressPreviousButton { newSong in
            completion(newSong)
        }
    }
    
    func didPressNextButton(completion: @escaping (Song) -> Void) {
        playerDelegate?.didPressNextButton { newSong in
            completion(newSong)
        }
    }
    
    func didPressPlayButton() {
        playerDelegate?.didPressPlayButton()
    }
    
    func didChangeTime(to newTime: TimeInterval) {
        playerDelegate?.didChangeTime(to: newTime)
    }
}

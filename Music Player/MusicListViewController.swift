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
    var songWasSelected: ((_ song: Song) -> Void)?
    fileprivate var album: Album?
    fileprivate let dataSource = SongsDataSource()
    weak var playerDelegate: PlayerViewControllerDelegate?
    weak var multipleDataOutput: LandingPageViewOutputMultipleValues?
    weak var songActionHandler: SongActionHandler?
    weak var musicActionHandler: MusicPlayerActionHandler?
    weak var audioPlayerDelegate: AudioPlayerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        musicTableView.dataSource = dataSource
        musicTableView.delegate = self
        musicTableView.register(UINib(nibName: "TrackCell", bundle: nil), forCellReuseIdentifier: TrackCell.identifier)
        fillLabels()
    }
    
    static func instance(from vc: UIViewController) -> MusicListViewController {
        let storyboard = UIStoryboard(name: "MusicList", bundle: nil)
        return storyboard.instantiateInitialViewController() as! MusicListViewController
    }
    
    private func fillLabels() {
        
        guard let album = self.album else {
            print("Album is nil")
            return
        }
        artistNameLabel.text = album.artistName
        albumNameLabel.text = album.name
    }
    
    func sizeForPopup(_ popupController: PopupController, size: CGSize, showingKeyboard: Bool) -> CGSize {
        let margin = UIScreen.main.bounds.height * 0.1
        if UIScreen.main.bounds.height > 700 {
            return CGSize(width: self.view.frame.width - 20, height: self.view.frame.height - margin * 1.5)
        }
        return CGSize(width: self.view.frame.width - 20, height: self.view.frame.height - margin)
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        closeHandler?()
    }
}

// MARK: - UITableViewDelegate
extension MusicListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let song = dataSource.getSongs()[indexPath.row]
        let playerViewController = PlayerViewController.instance()
        songWasSelected?(song)
        
        self.multipleDataOutput = playerViewController
        self.audioPlayerDelegate = playerViewController
        playerViewController.playerDelegate = self
        
        multipleDataOutput?.sendSongs(album!.songs)
        musicActionHandler?.songWasSelectedFromAlbum()
        songActionHandler?.musicWasSelected(song)
    }
}

// MARK: - LandingPageViewOutputMultipleValues
extension MusicListViewController: AlbumsActionHandler {
    
    func albumWasSelected(_ album: Album) {
        dataSource.setSongs(album.songs)
        self.album = album
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
        playerDelegate?.didPressPreviousButton{ newSong in
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

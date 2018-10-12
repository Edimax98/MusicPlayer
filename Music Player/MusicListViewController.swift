//
//  MusicListViewController.swift
//  Music Player
//
//  Created by Даниил on 20.09.2018.
//  Copyright © 2018 polat. All rights reserved.
//

import UIKit
import AVFoundation

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
    weak var playerViewController: PlayerViewController?
    
    deinit {
        print("List VC deinited")
    }
    
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
        playerViewController = PlayerViewController.instance()
        songWasSelected?(song)
        
        self.songActionHandler = playerViewController
        self.multipleDataOutput = playerViewController
        
        multipleDataOutput?.sendSongs(album!.songs)
        songActionHandler?.musicWasSelected(song)
        musicActionHandler?.songWasSelectedFromAlbum()
        
        let popupController = PopupController
            .createForRoot(of: self)
            .customize(
                [
                    .layout(.center),
                    .animation(.fadeIn),
                    .scrollable(false),
                    .backgroundStyle(.blackFilter(alpha: 0.7))
                ]
            )
            .show(playerViewController!)
        playerViewController!.closeHandler = {
            popupController.dismiss()
        }
    }
}

// MARK: - LandingPageViewOutputMultipleValues
extension MusicListViewController: AlbumsActionHandler {
    
    func albumWasSelected(_ album: Album) {
        dataSource.setSongs(album.songs)
        self.album = album
    }
}

extension MusicListViewController: PlayerViewControllerDelegate {
    
    func didPressPlayButton() {
        playerDelegate?.didPressPlayButton()
    }
    
    func didPressNextButton() {
        playerDelegate?.didPressNextButton()
    }
    
    func didPressPreviousButton() {
        playerDelegate?.didPressPreviousButton()
    }
    
    func didChangeTime(to newTime: TimeInterval) {
       playerDelegate?.didChangeTime(to: newTime)
    }
}

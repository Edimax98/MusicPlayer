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
    var closeWithAlbumPlaying: ((_ items: [AVPlayerItem]?,_ currentItemIndex: Int,_ time: CMTime?) -> Void)?
    var closeWithAlbumPaused: ((_ items: [AVPlayerItem]?,_ currentItemIndex: Int,_ time: CMTime?) -> Void)?
    
    fileprivate var album: Album?
    fileprivate let dataSource = SongsDataSource()
    fileprivate weak var multipleDataOutput: LandingPageViewOutputMultipleValues?
    fileprivate weak var songActionHandler: SongsActionHandler?
    weak var musicActionHandler: MusicPlayerActionHandler?
    
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
        
    class func instance() -> MusicListViewController {
        
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
        return CGSize(width: 350, height: 500)
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        closeHandler?()
    }
}

// MARK: - UITableViewDelegate
extension MusicListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let song = dataSource.getSongs()[indexPath.row]
    
        let vc = PlayerViewController.instance()
        self.songActionHandler = vc
        self.multipleDataOutput = vc
        
        multipleDataOutput?.sendSongs(album!.songs)
        songActionHandler?.musicWasSelected(song)
        musicActionHandler?.songWasSelectedFromAlbum()
        
        let popupController = PopupController
            .create(self)
            .customize(
                [
                    .layout(.top),
                    .animation(.fadeIn),
                    .scrollable(false),
                    .backgroundStyle(.blackFilter(alpha: 0.7))
                ]
            )
            .show(vc)
        
        vc.closeWithSongPlaying = { (_,_) in
            popupController.dismiss()
        }
        
        vc.closeWithAlbumPaused = { [weak self] (items, index, time) in
            guard let unwrappedSelf = self else { return }
            unwrappedSelf.closeWithAlbumPaused?(items,index,time)
            popupController.dismiss()
        }
        
        vc.closeWithAlbumPlaying = { [weak self] (items, index, time) in
            guard let unwrappedSelf = self else { return }
            unwrappedSelf.closeWithAlbumPlaying?(items,index,time)
            popupController.dismiss()
        }
        
        vc.closeHandler = {
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

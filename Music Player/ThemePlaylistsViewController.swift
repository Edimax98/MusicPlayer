//
//  ThemePlaylistsViewController.swift
//  Music Player
//
//  Created by Даниил on 16/11/2018.
//  Copyright © 2018 polat. All rights reserved.
//

import UIKit

class ThemePlaylistsViewController: UIViewController {

    @IBOutlet weak var themeTitleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    fileprivate let cellHeight: CGFloat = 180
    var interactor: MusicPlayerLandingPageInteractor?
    
    private let dataSource = ThemePlaylistsDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "ThemePlaylistCell", bundle: nil), forCellWithReuseIdentifier: ThemePlaylistCell.identifier)
        let networkService = NetworkService()
        interactor = MusicPlayerLandingPageInteractor(networkService)
        interactor?.fetchSongs(amount: 10, tags: ["Holidays"])
        interactor?.themePlaylistOutput = self
    }
}

extension ThemePlaylistsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewSize = collectionView.frame.size.width - 20
        return CGSize(width: collectionViewSize / 2, height: cellHeight)
    }
}

extension ThemePlaylistsViewController: ThemePlaylistInteractorOutput {
    
    func sendPlaylist(_ playlists: [Album], theme: String) {
        
        themeTitleLabel.text = theme
        dataSource.setPlaylists(playlists)
        collectionView.reloadData()
    }
}

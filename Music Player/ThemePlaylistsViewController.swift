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
    var theme: String?
    
    private let dataSource = ThemePlaylistsDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "ThemePlaylistCell", bundle: nil), forCellWithReuseIdentifier: ThemePlaylistCell.identifier)
        let networkService = NetworkService()
        interactor = MusicPlayerLandingPageInteractor(networkService)
        interactor?.themePlaylistOutput = self
        
        if let unwrappedTheme = theme {
            themeTitleLabel.text = unwrappedTheme
            interactor?.fetchSongs(amount: 10, tags: [unwrappedTheme])
        }
    }
    
    @IBAction func closeView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension ThemePlaylistsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewSize = collectionView.frame.size.width - 40
        return CGSize(width: collectionViewSize / 2, height: cellHeight - 50)
    }
}

extension ThemePlaylistsViewController: ThemePlaylistInteractorOutput {
    
    func sendPlaylist(_ playlists: [Album], theme: String) {
        
        dataSource.setPlaylists(playlists)
        collectionView.reloadData()
    }
}

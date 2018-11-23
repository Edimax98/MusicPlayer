//
//  ThemePlaylistsDataSource.swift
//  Music Player
//
//  Created by Даниил on 16/11/2018.
//  Copyright © 2018 polat. All rights reserved.
//

import UIKit

class ThemePlaylistsDataSource: NSObject {
    
    private var playlists = [Album(name: "First", artistName: "Somebody", imagePath: "", songs: []),
                             Album(name: "Second", artistName: "Somebody", imagePath: "", songs: []),
                             Album(name: "Third", artistName: "Somebody", imagePath: "", songs: []),
                             Album(name: "Fourth", artistName: "Somebody", imagePath: "", songs: [])]

    func setPlaylists(_ playlists: [Album]) {
        self.playlists = playlists
    }
    
    func getPlaylists() -> [Album] {
        return self.playlists
    }
}

// MARK: - UICollectionViewDataSource
extension ThemePlaylistsDataSource: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return playlists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ThemePlaylistCell.identifier, for: indexPath) as? ThemePlaylistCell else {
            return UICollectionViewCell()
        }
        
        cell.playlistImageView.image = playlists[indexPath.row].image
        return cell
    }
}

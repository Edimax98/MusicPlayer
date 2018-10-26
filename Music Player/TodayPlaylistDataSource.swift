//
//  TodayPlaylistDataSource.swift
//  Music Player
//
//  Created by Даниил on 26/09/2018.
//  Copyright © 2018 polat. All rights reserved.
//

import UIKit

class TodaysPlaylistDataSource: NSObject {
    
    fileprivate var playlists = [Album]()
    fileprivate let playlistsCoverNames = ["playlist1","playlist2","playlist3","playlist4","playlist5", "playlist6"]

    func setPlaylists(_ playlists: [Album]) {
        self.playlists = playlists
    }
    
    func getPlaylists() -> [Album] {
        return self.playlists
    }
}

// MARK: - UICollectionViewDataSource
extension TodaysPlaylistDataSource: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return playlists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let playlist = playlists[indexPath.row]
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TodaySongCell.identifier, for: indexPath) as? TodaySongCell else {
            print("Could not dequeue today playlist cell")
            return UICollectionViewCell()
        }
        
        cell.typeOfPlaylistLabel.text = playlist.name + " Collection"
        cell.infoAboutPlaylistLabel.text = playlist.artistName
        let indexForImage = indexPath.row
        
        if indexForImage <= playlistsCoverNames.count - 1 {
            cell.playlistCoverImageView.image = UIImage(named: playlistsCoverNames[indexForImage])
        } else {
            cell.playlistCoverImageView.image = UIImage(named: playlistsCoverNames.first!)
        }
        return cell
    }
}

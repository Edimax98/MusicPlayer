//
//  PopularSongsDataSource.swift
//  Music Player
//
//  Created by Даниил on 18.09.2018.
//  Copyright © 2018 polat. All rights reserved.
//

import UIKit

class PopularSongsDataSource: NSObject {
    
    fileprivate var songs: [Song]
    
    init(songs: [Song]) {
        self.songs = songs
    }
}

// MARK: - UICollectionViewDataSource
extension PopularSongsDataSource: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return songs.count * 5 ///!!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SongCell.identifier, for: indexPath) as? SongCell else {
            print("Could not dequeu cell with identifeir - \(SongCell.identifier)")
            return UICollectionViewCell()
        }
    
        cell.songCoverImageView.image = UIImage(named: "albom1")
        cell.songNameLabel.text = songs[0].name
        cell.songArtistNameLabel.text = songs[0].artistName
        
        return cell
    }
}

//
//  PopularSongsDataSource.swift
//  Music Player
//
//  Created by Даниил on 18.09.2018.
//  Copyright © 2018 polat. All rights reserved.
//

import UIKit
import AlamofireImage
import Alamofire

class PopularSongsDataSource: NSObject {
    
    fileprivate var songs = [Song]()
    
    func setSongs(_ songs: [Song]) {
        self.songs = songs
    }
}

// MARK: - UICollectionViewDataSource
extension PopularSongsDataSource: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return songs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let song = songs[indexPath.row]
        let queue = DispatchQueue.global(qos: .utility)
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SongCell.identifier, for: indexPath) as? SongCell else {
            print("Could not dequeu cell with identifeir - \(SongCell.identifier)")
            return UICollectionViewCell()
        }
        
        queue.async {
            request(song.imagePath, method: .get, parameters: nil, encoding: URLEncoding(), headers: nil)
                .responseImage { (response) in
                    if let image = response.result.value {
                        DispatchQueue.main.async {
                            cell.songCoverImageView.image = image
                        }
                    }
            }
        }
        
        cell.songNameLabel.text = song.name
        cell.songArtistNameLabel.text = song.artistName
        return cell
    }
}

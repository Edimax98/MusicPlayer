//
//  NewReleasesDataSource.swift
//  Music Player
//
//  Created by Даниил on 18.09.2018.
//  Copyright © 2018 polat. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class NewReleasesDataSource: NSObject {
    
    fileprivate var albums = [Album]()
    
    func setAlbums(_ albums: [Album]) {
        self.albums = albums
    }
}

extension NewReleasesDataSource: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var album = albums[indexPath.row]
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewAlbumCell.identifier, for: indexPath) as? NewAlbumCell else {
            return UICollectionViewCell()
        }
        
        request(album.imagePath, method: .get, parameters: nil, encoding: URLEncoding(), headers: nil).responseImage { (response) in
            
            if let image = response.result.value {
                DispatchQueue.main.async {
                    cell.newAlbumCoverImageView.image = image
                    album.image = image
                }
            } else {
                print("image is nil")
            }
        }
        
        cell.albumAuthorNameLabel.text = album.artistName
        cell.albumNameLabel.text = album.name
        
        return cell
    }
}

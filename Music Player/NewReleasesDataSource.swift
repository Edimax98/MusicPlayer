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
    
    func getAlbums() -> [Album] {
        return self.albums
    }
}

extension NewReleasesDataSource: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let album = albums[indexPath.row]
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewAlbumCell.identifier, for: indexPath) as? NewAlbumCell else {
            return UICollectionViewCell()
        }
    
        cell.newAlbumCoverImageView.image = album.image
        cell.albumAuthorNameLabel.text = album.artistName
        cell.albumNameLabel.text = album.name
        
        return cell
    }
}

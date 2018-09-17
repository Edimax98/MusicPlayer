//
//  AlbumCollectionViewDataSource.swift
//  Music Player
//
//  Created by Даниил on 17.09.2018.
//  Copyright © 2018 polat. All rights reserved.
//

import UIKit

class AlbumCollectionViewDataSource: NSObject {
    
    fileprivate var albums: [Album]
    
    init(albums: [Album]) {
        self.albums = albums
    }
}

extension AlbumCollectionViewDataSource: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewAlbumCell.identifier, for: indexPath) as? NewAlbumCell else {
            return UICollectionViewCell()
        }
        
        return cell
    }
}


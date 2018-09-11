//
//  PopularSongsCell.swift
//  Music Player
//
//  Created by Даниил Смирнов on 09.09.2018.
//  Copyright © 2018 polat. All rights reserved.
//

import UIKit

class PopularSongsCell: UITableViewCell {
    
    var hanlder: ActionHandler?
    static var identifier = "PopularSongsCell"
    let bunchOfSongCovers = ["albom1","albom2","albom3","albom4",
                             "albom5","albom6","albom7","albom8",
                             "albom9","albom10","albom11","albom12"]
    
    @IBOutlet weak var popularSongsCollectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if popularSongsCollectionView != nil {
            popularSongsCollectionView.dataSource = self
            popularSongsCollectionView.delegate = self
            popularSongsCollectionView.register(UINib(nibName: "SongCell", bundle: nil), forCellWithReuseIdentifier: "SongCell")
        }
    }
}

extension PopularSongsCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bunchOfSongCovers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SongCell", for: indexPath) as? SongCell else {
            return UICollectionViewCell()
        }
        
        cell.songCoverImageView.image = UIImage(named: bunchOfSongCovers[indexPath.row])
        return cell
    }
}

extension PopularSongsCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        hanlder?.musicWasSelected(with: bunchOfSongCovers[indexPath.row])
    }
}



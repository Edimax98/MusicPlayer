//
//  PopularSongsCell.swift
//  Music Player
//
//  Created by Даниил Смирнов on 09.09.2018.
//  Copyright © 2018 polat. All rights reserved.
//

import UIKit

class PopularSongsCell: UITableViewCell {
    
    weak var hanlder: SongsActionHandler?
    var songsDataSource = PopularSongsDataSource()
    static var identifier = "PopularSongsCell"
    
    @IBOutlet weak var popularSongsCollectionView: UICollectionView!
    fileprivate let defaultBackgroundColor = UIColor(red: 13 / 255, green: 15 / 255, blue: 22 / 255, alpha: 1)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
        popularSongsCollectionView.backgroundColor = defaultBackgroundColor
        popularSongsCollectionView.dataSource = songsDataSource
        popularSongsCollectionView.delegate = self
        popularSongsCollectionView.register(UINib(nibName: "SongCell", bundle: nil), forCellWithReuseIdentifier: SongCell.identifier)
    }
}

extension PopularSongsCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
}

extension PopularSongsCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let song = songsDataSource.getSongs()[indexPath.row]
        hanlder?.musicWasSelected(song)
    }
}

extension PopularSongsCell: SongsInteractorOutput {
    
    func sendSongs(_ songs: [Song]) {
        songsDataSource.setSongs(songs)
        popularSongsCollectionView.reloadData()
    }
}





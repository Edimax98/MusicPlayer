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
    private var songsDataSource = PopularSongsDataSource(songs: [])
    let bunchOfSongCovers = ["albom1","albom2","albom3","albom4",
                             "albom5","albom6","albom7","albom8",
                             "albom9","albom10","albom11","albom12"]
    
    static var identifier = "PopularSongsCell"
    
    @IBOutlet weak var popularSongsCollectionView: UICollectionView!
    fileprivate let defaultBackgroundColor = UIColor(red: 13 / 255, green: 15 / 255, blue: 22 / 255, alpha: 1)

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
      //  if popularSongsCollectionView != nil {
            popularSongsCollectionView.backgroundColor = defaultBackgroundColor
            popularSongsCollectionView.dataSource = songsDataSource
            popularSongsCollectionView.delegate = self
            popularSongsCollectionView.register(UINib(nibName: "SongCell", bundle: nil), forCellWithReuseIdentifier: SongCell.identifier)
        //}
    }
}

extension PopularSongsCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: 100)
    }
}

extension PopularSongsCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        hanlder?.musicWasSelected(with: bunchOfSongCovers[indexPath.row])
    }
}

extension PopularSongsCell: MusicPlayerInteractorOutput {
    
    func sendSongs(_ songs: [Song]) {
        songsDataSource = PopularSongsDataSource(songs: songs)
        popularSongsCollectionView.reloadData()
    }
}





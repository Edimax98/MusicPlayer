 //
//  TodaysPlaylistCell.swift
//  Music Player
//
//  Created by Даниил Смирнов on 09.09.2018.
//  Copyright © 2018 polat. All rights reserved.
//

import UIKit

class TodaysPlaylistCell: UITableViewCell {
    
    @IBOutlet weak var todaysPlaylistCollectionView: UICollectionView!
    
    fileprivate let defaultBackgroundColor = UIColor(red: 13 / 255, green: 15 / 255, blue: 22 / 255, alpha: 1)
    fileprivate let playlistsCoverNames = ["playlist1","playlist2","playlist3","playlist4"]
    fileprivate let cellWidth: CGFloat = 144
    fileprivate let cellHeight: CGFloat = 140
    static var identifier = "TodaysPlaylistCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        if todaysPlaylistCollectionView != nil {
            todaysPlaylistCollectionView.register(UINib(nibName: "TodaySongCell", bundle: nil), forCellWithReuseIdentifier: TodaySongCell.identifier)
            todaysPlaylistCollectionView.backgroundColor = defaultBackgroundColor
            todaysPlaylistCollectionView.dataSource = self
            todaysPlaylistCollectionView.delegate = self
        }
    }
}

extension TodaysPlaylistCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return playlistsCoverNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TodaySongCell.identifier, for: indexPath) as? TodaySongCell else {
            return UICollectionViewCell()
        }
        
        cell.playlistCoverImageView.image = UIImage(named: playlistsCoverNames[indexPath.row])!
        return cell
    }
}

extension TodaysPlaylistCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: cellHeight)
    }
}










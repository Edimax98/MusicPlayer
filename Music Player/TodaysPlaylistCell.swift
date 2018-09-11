 //
//  TodaysPlaylistCell.swift
//  Music Player
//
//  Created by Даниил Смирнов on 09.09.2018.
//  Copyright © 2018 polat. All rights reserved.
//

import UIKit

class TodaysPlaylistCell: UITableViewCell {
    
    fileprivate let playlistsCoverNames = ["playlist1","playlist2","playlist3","playlist4"]
    fileprivate let offset: CGFloat = 75
    static var identifier = "TodaysPlaylistCell"
    @IBOutlet weak var todaysPlaylistCollectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if todaysPlaylistCollectionView != nil {
            todaysPlaylistCollectionView.register(UINib(nibName: "TodaySongCell", bundle: nil), forCellWithReuseIdentifier: "TodaySongCell")
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
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TodaySongCell", for: indexPath) as? TodaySongCell else {
            return UICollectionViewCell()
        }
        cell.playlistCoverImageView.image = UIImage(named: playlistsCoverNames[indexPath.row])!
        return cell
    }
}

extension TodaysPlaylistCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.frame.width - offset, height: self.frame.height - 10)
    }
}










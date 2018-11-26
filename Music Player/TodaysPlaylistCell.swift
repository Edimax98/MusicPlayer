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
    fileprivate let cellWidth: CGFloat = 144
    fileprivate let cellHeight: CGFloat = 150
    let mediator = Mediator()
    var dataSource = TodaysPlaylistDataSource()
    var shouldArtificiallyPressCell = false
    static var identifier = "TodaysPlaylistCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        if todaysPlaylistCollectionView != nil {
            todaysPlaylistCollectionView.register(UINib(nibName: "TodaySongCell", bundle: nil), forCellWithReuseIdentifier: TodaySongCell.identifier)
            todaysPlaylistCollectionView.backgroundColor = defaultBackgroundColor
            todaysPlaylistCollectionView.dataSource = dataSource
            todaysPlaylistCollectionView.delegate = self
        }
    }
}

// MARK: - UICollectionViewDelegate
 extension TodaysPlaylistCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let album = dataSource.getPlaylists()[indexPath.row]
        
        //guard mediator.recipients.isEmpty == false else { mediator.denyAccess(); return }
        
        mediator.send(album: album)
    }
 }
 
// MARK: - UICollectionViewDelegateFlowLayout
extension TodaysPlaylistCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: cellHeight)
    }
}
 
// MARK: - ThemePlaylistInteractorOutput
extension TodaysPlaylistCell: ThemePlaylistInteractorOutput {
    
    func sendPlaylist(_ playlists: [Album], theme: String) {
        dataSource.setPlaylists(playlists)
        todaysPlaylistCollectionView.reloadData()
        
        if shouldArtificiallyPressCell {
            collectionView(todaysPlaylistCollectionView, didSelectItemAt: IndexPath(row: 0, section: 0))
        }
    }
 }
 









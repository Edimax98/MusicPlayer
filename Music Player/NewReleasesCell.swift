//
//  NewReleasesCell.swift
//  Music Player
//
//  Created by Даниил Смирнов on 09.09.2018.
//  Copyright © 2018 polat. All rights reserved.
//

import UIKit

class NewReleasesCell: UITableViewCell {
    
    @IBOutlet weak var collectionViewLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var releasesCollectionVeiw: UICollectionView!
    
    weak var handler: AlbumsActionHandler?
    var dataSource = NewReleasesDataSource()
    
    static var identifier: String {
        return "NewReleasesCell"
    }
    
    fileprivate let defaultBackgroundColor = UIColor(red: 13 / 255, green: 15 / 255, blue: 22 / 255, alpha: 1)
    fileprivate var bunchOfNewAlbumCovers = ["rel1","rel2","rel3","rel4","rel5"]
    fileprivate var indexOfCellBeforeDragging = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        if releasesCollectionVeiw != nil {
            setupLayout()
            releasesCollectionVeiw.delegate = self
            releasesCollectionVeiw.dataSource = dataSource
            releasesCollectionVeiw.backgroundColor = defaultBackgroundColor
            releasesCollectionVeiw.register(UINib(nibName: "NewAlbumCell", bundle: nil), forCellWithReuseIdentifier: NewAlbumCell.identifier)
        }
    }

    fileprivate func setupLayout() {
        let layout = releasesCollectionVeiw.collectionViewLayout as! UPCarouselFlowLayout
        layout.spacingMode = UPCarouselFlowLayoutSpacingMode.fixed(spacing: 5)
    }
}

// MARK: - UICollectionViewDelegate
extension NewReleasesCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var album = dataSource.getAlbums()[indexPath.row]
        
        guard let selectedCell = collectionView.cellForItem(at: indexPath) as? NewAlbumCell else {
            print("Could not cast selected cell to NewAlbumCell")
            return
        }
        
        var i = 0
        while(i <= album.songs.count - 1) {
            album.songs[i].image = selectedCell.newAlbumCoverImageView.image
            i += 1
        }
        
        handler?.albumWasSelected(album)
    }
}

// MARK: - AlbumInteractorOutput
extension NewReleasesCell: AlbumInteractorOutput {
    
    func sendAlbums(_ albums: [Album]) {
        dataSource.setAlbums(albums)
        releasesCollectionVeiw.reloadData()
    }
}







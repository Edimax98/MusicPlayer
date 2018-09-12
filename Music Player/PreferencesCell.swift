//
//  PreferencesCell.swift
//  Music Player
//
//  Created by Даниил Смирнов on 09.09.2018.
//  Copyright © 2018 polat. All rights reserved.
//

import UIKit

class PreferencesCell: UITableViewCell {
    
    static var identifier: String {
        return "PreferencesCell"
    }
    
    var oneLineHeight: CGFloat {
        return 54.0
    }
    
    var longString = "Rock'n'Roll"
    
    var longTagIndex: Int {
        return 1
    }
        
    fileprivate let cellHeight: CGFloat = 37
    fileprivate let inset: CGFloat = 10
    fileprivate let minimumInteritemSpacing: CGFloat = 10
    fileprivate let cellsPerRow = 3
    fileprivate let countOfItemsInSection = 2
    fileprivate let preferedGenres = [["Indie Rock", "Deep House","Hip-Hop"],
                                      ["Trance","EDM","Trap"],
                                      ["Lounge","Rock'n'Roll","Classical"],
                                      ["House","Minimal","Psy Trance"],
                                      ["Alternative","Jazz","Country","Disco"]]
    
    @IBOutlet weak var preferencesCollectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        preferencesCollectionView.allowsMultipleSelection = true
        preferencesCollectionView.delegate = self
        preferencesCollectionView.register(UINib(nibName: PreferedGenreCell.identifier, bundle: nil), forCellWithReuseIdentifier: PreferedGenreCell.identifier)
        preferencesCollectionView.dataSource = self
    }
}

extension PreferencesCell: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PreferedGenreCell.identifier, for: indexPath) as? PreferedGenreCell else {
            return UICollectionViewCell()
        }
        
        cell.preferedGenreLabel.text = preferedGenres[indexPath.section][indexPath.row]
        return cell
    }
}

extension PreferencesCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let marginsAndInsets = inset * 2.0 + collectionView.safeAreaInsets.left + collectionView.safeAreaInsets.right + minimumInteritemSpacing * CGFloat(cellsPerRow - 1)
        let itemWidth = ((collectionView.bounds.size.width - marginsAndInsets) / CGFloat(cellsPerRow)).rounded(.down)
        return CGSize(width: itemWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
}

extension PreferencesCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? PreferedGenreCell else {
            return
        }
        
        cell.preferedGenreImageView.image = nil
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? PreferedGenreCell else {
            return
        }
        
        if indexPath.row % 2 == 0 {
            cell.preferedGenreImageView.image = UIImage(named: "genresblue")
        } else if indexPath.row % 3 == 0 {
            cell.preferedGenreImageView.image = UIImage(named: "genresblue")
        } else {
            cell.preferedGenreImageView.image = UIImage(named: "genresgreen")
        }
    }
}






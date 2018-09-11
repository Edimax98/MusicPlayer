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
    fileprivate let cellHeight: CGFloat = 37
    fileprivate let inset: CGFloat = 10
    fileprivate let minimumInteritemSpacing: CGFloat = 10
    fileprivate let cellsPerRow = 3
    fileprivate let countOfItemsInSection = 2
    fileprivate let preferedGenres = ["Indie Rock", "Deep House","Hip-Hop", "Trance",
                                      "EDM","Trap","Lounge","Rock'n'Roll",
                                      "Classical","House","Minimal","Psy Trance",
                                      "Alternative","Jazz","Country","Disco"]
    
    @IBOutlet weak var preferencesCollectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        preferencesCollectionView.delegate = self
        preferencesCollectionView.register(UINib(nibName: "PreferedGenreCell", bundle: nil), forCellWithReuseIdentifier: "PreferedGenreCell")
        preferencesCollectionView.dataSource = self
    }
}

extension PreferencesCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return preferedGenres.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PreferedGenreCell", for: indexPath) as? PreferedGenreCell else {
            return UICollectionViewCell()
        }
        
        cell.preferedGenreLabel.text = preferedGenres[indexPath.row]
        return cell
    }
}

extension PreferencesCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let marginsAndInsets = inset * 2.0 + collectionView.safeAreaInsets.left + collectionView.safeAreaInsets.right + minimumInteritemSpacing * CGFloat(cellsPerRow - 1)
        let itemWidth = ((collectionView.bounds.size.width - marginsAndInsets) / CGFloat(cellsPerRow)).rounded(.down)
        return CGSize(width: itemWidth, height: cellHeight)
    }
}

extension PreferencesCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        collectionView.deselectItem(at: indexPath, animated: false)
//        let shadowedRed = UIColor(red: 255 / 221, green: 255 / 46, blue: 255 / 81, alpha: 1)
//        let brightGreen = UIColor(red: 255 / 117, green: 255 / 255, blue: 255 / 140, alpha: 1)
//        let shadowedYellow = UIColor(red: 255 / 255, green: 255 / 196, blue: 255 / 58, alpha: 1)
//
//        guard let cell = collectionView.cellForItem(at: indexPath) as? PreferedGenreCell else {
//            return
//        }
//
//        if indexPath.row % 2 == 0 {
//            cell.preferedGenreLabel.text = "lelrfg"
//        } else if indexPath.row % 3 == 0 {
//            cell.backgroundColor = .green
//        } else {
//            cell.backgroundColor = shadowedRed
//        }
//        preferencesCollectionView.reloadItems(at: [indexPath])
    }
}






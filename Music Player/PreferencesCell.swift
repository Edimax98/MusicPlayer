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
    
    fileprivate let defaultBackgroundColor = UIColor(red: 13 / 255, green: 15 / 255, blue: 22 / 255, alpha: 1)
    fileprivate let cellHeight: CGFloat = 37
    fileprivate let inset: CGFloat = 10
    fileprivate let minimumInteritemSpacing: CGFloat = 10
    fileprivate let cellsPerRow = 3
    fileprivate let countOfItemsInSection = 2
    fileprivate let preferedGenres = ["Indie Rock", "Deep House","Hip-Hop", "Jazz", "Country", "Disco"]
    fileprivate let genresImages = ["genrespink","genresgreen","genresblue","genresorange"]
    
    @IBOutlet weak var preferencesCollectionView: UICollectionView!
    @IBOutlet weak var preferencesSecondLineCollectionView: UICollectionView!
    @IBOutlet weak var preferencesThirdLineCollectionView: UICollectionView!
    @IBOutlet weak var preferencesFourthLineCollectionView: UICollectionView!
    @IBOutlet weak var preferencesFifthLineCollecctionview: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        preferencesCollectionView.backgroundColor = defaultBackgroundColor
        preferencesSecondLineCollectionView.backgroundColor = defaultBackgroundColor
        preferencesThirdLineCollectionView.backgroundColor = defaultBackgroundColor
        preferencesFourthLineCollectionView.backgroundColor = defaultBackgroundColor
        preferencesFifthLineCollecctionview.backgroundColor = defaultBackgroundColor
        self.backgroundColor = defaultBackgroundColor
        preferencesSecondLineCollectionView.dataSource = self
        preferencesSecondLineCollectionView.delegate = self
        preferencesThirdLineCollectionView.dataSource = self
        preferencesThirdLineCollectionView.delegate = self
        preferencesFourthLineCollectionView.delegate = self
        preferencesFourthLineCollectionView.dataSource = self
        preferencesFifthLineCollecctionview.dataSource = self
        preferencesFifthLineCollecctionview.delegate = self
        preferencesCollectionView.allowsMultipleSelection = true
        preferencesSecondLineCollectionView.allowsMultipleSelection = true
        preferencesThirdLineCollectionView.allowsMultipleSelection = true
        preferencesFourthLineCollectionView.allowsMultipleSelection = true
        preferencesFifthLineCollecctionview.allowsMultipleSelection = true
        preferencesCollectionView.delegate = self
        preferencesCollectionView.dataSource = self
        preferencesSecondLineCollectionView.register(UINib(nibName: PreferedGenreCell.identifier, bundle: nil), forCellWithReuseIdentifier: PreferedGenreCell.identifier)
        preferencesThirdLineCollectionView.register(UINib(nibName: PreferedGenreCell.identifier, bundle: nil), forCellWithReuseIdentifier: PreferedGenreCell.identifier)
        preferencesFourthLineCollectionView.register(UINib(nibName: PreferedGenreCell.identifier, bundle: nil), forCellWithReuseIdentifier: PreferedGenreCell.identifier)
        preferencesCollectionView.register(UINib(nibName: PreferedGenreCell.identifier, bundle: nil), forCellWithReuseIdentifier: PreferedGenreCell.identifier)
        preferencesFifthLineCollecctionview.register(UINib(nibName: PreferedGenreCell.identifier, bundle: nil), forCellWithReuseIdentifier: PreferedGenreCell.identifier)
    }
}

extension PreferencesCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return preferedGenres.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PreferedGenreCell.identifier, for: indexPath) as? PreferedGenreCell else {
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
        
        let randomNumber = Int(arc4random() % 4)
        cell.preferedGenreImageView.image = UIImage(named: genresImages[randomNumber])
    }
}






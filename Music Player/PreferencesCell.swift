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
    fileprivate let preferedGenres = ["Indie Rock", "Deep House","Hip-Hop", "Jazz", "Country"]
    fileprivate let preferedGenresSecondLine = ["Beats", "Float House","EDM", "DeepHouse", "Trance", "Techno"]
    fileprivate let preferedGenresThirdLine = ["Art Pop", "Rock", "Classical", "Trap", "Pop", "Neo Soul"]
    fileprivate let preferedGenresFourthLine = ["Modern Rock", "Chill", "Chill Lounge", "Bass Trap", "Dance Pop"]
    fileprivate let preferedGenresFifthLine = ["Electro Jazz", "J-Core","Pop Rock", "K-Pop", "Rif"]
    fileprivate let genresImages = ["genrespink","genresgreen","genresblue","genresorange"]
    
    @IBOutlet weak var preferencesCollectionView: UICollectionView!
    @IBOutlet weak var preferencesSecondLineCollectionView: UICollectionView!
    @IBOutlet weak var preferencesThirdLineCollectionView: UICollectionView!
    @IBOutlet weak var preferencesFourthLineCollectionView: UICollectionView!
    @IBOutlet weak var preferencesFifthLineCollecctionview: UICollectionView!
    
    private func registerCells() {
        
        preferencesSecondLineCollectionView.register(UINib(nibName: PreferedGenreCell.identifier, bundle: nil),
                                                     forCellWithReuseIdentifier: PreferedGenreCell.identifier)
        preferencesThirdLineCollectionView.register(UINib(nibName: PreferedGenreCell.identifier, bundle: nil),
                                                    forCellWithReuseIdentifier: PreferedGenreCell.identifier)
        preferencesFourthLineCollectionView.register(UINib(nibName: PreferedGenreCell.identifier, bundle: nil),
                                                     forCellWithReuseIdentifier: PreferedGenreCell.identifier)
        preferencesCollectionView.register(UINib(nibName: PreferedGenreCell.identifier, bundle: nil),
                                           forCellWithReuseIdentifier: PreferedGenreCell.identifier)
        preferencesFifthLineCollecctionview.register(UINib(nibName: PreferedGenreCell.identifier, bundle: nil),
                                                     forCellWithReuseIdentifier: PreferedGenreCell.identifier)
    }
    
    private func setDataSourcesAndDelegates() {
        
        preferencesSecondLineCollectionView.dataSource = self
        preferencesSecondLineCollectionView.delegate = self
        preferencesThirdLineCollectionView.dataSource = self
        preferencesThirdLineCollectionView.delegate = self
        preferencesFourthLineCollectionView.delegate = self
        preferencesFourthLineCollectionView.dataSource = self
        preferencesFifthLineCollecctionview.dataSource = self
        preferencesFifthLineCollecctionview.delegate = self
        preferencesCollectionView.delegate = self
        preferencesCollectionView.dataSource = self
    }
    
    private func setupCollectionView() {
        
        self.selectionStyle = .none
        self.backgroundColor = defaultBackgroundColor
        preferencesCollectionView.backgroundColor = defaultBackgroundColor
        preferencesSecondLineCollectionView.backgroundColor = defaultBackgroundColor
        preferencesThirdLineCollectionView.backgroundColor = defaultBackgroundColor
        preferencesFourthLineCollectionView.backgroundColor = defaultBackgroundColor
        preferencesFifthLineCollecctionview.backgroundColor = defaultBackgroundColor
        
        preferencesCollectionView.allowsMultipleSelection = true
        preferencesSecondLineCollectionView.allowsMultipleSelection = true
        preferencesThirdLineCollectionView.allowsMultipleSelection = true
        preferencesFourthLineCollectionView.allowsMultipleSelection = true
        preferencesFifthLineCollecctionview.allowsMultipleSelection = true

        registerCells()
        setDataSourcesAndDelegates()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCollectionView()
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
    
        if collectionView === preferencesCollectionView {
            cell.preferedGenreLabel.text = preferedGenres[indexPath.row]
            return cell
        }
        
        if collectionView === preferencesSecondLineCollectionView {
            cell.preferedGenreLabel.text = preferedGenresSecondLine[indexPath.row]
            return cell
        }
        
        if collectionView === preferencesThirdLineCollectionView {
            cell.preferedGenreLabel.text = preferedGenresThirdLine[indexPath.row]
            return cell
        }
        
        if collectionView === preferencesFourthLineCollectionView {
            cell.preferedGenreLabel.text = preferedGenresFourthLine[indexPath.row]
            return cell
        }
        
        if collectionView === preferencesFifthLineCollecctionview {
            cell.preferedGenreLabel.text = preferedGenresFifthLine[indexPath.row]
            return cell
        }
        
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






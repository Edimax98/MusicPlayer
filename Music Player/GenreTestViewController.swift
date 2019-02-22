//
//  GenreTestViewController.swift
//  Music Player
//
//  Created by Даниил on 21/02/2019.
//  Copyright © 2019 polat. All rights reserved.
//

import UIKit

class GenreTestViewController: UIViewController {

    @IBOutlet weak var genresCollectionView: UICollectionView!
    
    var genres = ["EDM", "Deep House", "Hip-Hop", "Jazz", "Country", "Minimal",
                  "Classical", "Lounge", "Rock'N'Roll", "Disco", "Alternative",
                  "Indie Rock", "Trance", "Trap", "R&B", "Death Metall", "House",
                  "Pop", "Soul", "Latin"]
    
    var genresImages = ["genre1","genre2","genre3","genre4","genre5",
                        "genre6","genre7","genre8","genre9","genre10",
                        "genre11","genre12","genre13","genre14","genre15",
                        "genre16","genre17","genre18","genre19","genre20"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        genresCollectionView.delegate = self
        genresCollectionView.dataSource = self
        genresCollectionView.allowsMultipleSelection = true
        genresCollectionView.register(UINib(nibName: "TestGenreCell", bundle: nil), forCellWithReuseIdentifier: TestGenreCell.identifier)
//        genresCollectionView.register(UINib(nibName: "GenreTestViewController", bundle: nil), forSupplementaryViewOfKind: UIcollectiovi, withReuseIdentifier: GenreCollectionViewHeader.identifier)
    }
}

extension GenreTestViewController: UICollectionViewDelegateFlowLayout {
    
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let padding: CGFloat = 60
        
        let collectionViewSize = collectionView.frame.size.width - padding
        
        return CGSize(width: collectionViewSize / 2, height: 90)
    }
}

extension GenreTestViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? TestGenreCell else {
            return
        }
        
        cell.backImageView.alpha = 0.4
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
        guard let cell = collectionView.cellForItem(at: indexPath) as? TestGenreCell else {
            return
        }
        
        cell.backImageView.alpha = 1
    }
}

extension GenreTestViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
    
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if (kind == UICollectionElementKindSectionHeader) {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: GenreCollectionViewHeader.identifier, for: indexPath)
            
            return headerView
        } else {
            return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return genres.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TestGenreCell.identifier, for: indexPath) as? TestGenreCell else {
            return UICollectionViewCell()
        }
        
        if let image = UIImage(named: genresImages[indexPath.row]) {
            cell.backImageView.image = image
        }
        
        cell.genreLabel.text = genres[indexPath.row]
        
        return cell
    }
}


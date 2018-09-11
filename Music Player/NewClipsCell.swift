//
//  NewClipsCell.swift
//  Music Player
//
//  Created by Даниил Смирнов on 09.09.2018.
//  Copyright © 2018 polat. All rights reserved.
//

import UIKit

class NewClipsCell: UITableViewCell {

    @IBOutlet weak var clipsCollectionView: UICollectionView!
    
    static var identifier = "NewClipsCell"
    
    fileprivate let offset: CGFloat = 20
    fileprivate let widthForCell: CGFloat = 300
    fileprivate let countOfItems = 4
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if clipsCollectionView != nil {
            clipsCollectionView.dataSource = self
            clipsCollectionView.delegate = self
            clipsCollectionView.register(UINib(nibName: "ClipCell", bundle: nil), forCellWithReuseIdentifier: "ClipCell")
        }
    }
}

extension NewClipsCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return countOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ClipCell", for: indexPath) as? ClipCell else {
            return UICollectionViewCell()
        }
        return cell
    }
}

extension NewClipsCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: widthForCell, height: self.frame.height)
    }
}

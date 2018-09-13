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
    
    fileprivate let defaultBackgroundColor = UIColor(red: 13 / 255, green: 15 / 255, blue: 22 / 255, alpha: 1)
    fileprivate let offset: CGFloat = 20
    fileprivate let widthForCell: CGFloat = 300
    fileprivate let countOfItems = 4
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        if clipsCollectionView != nil {
            clipsCollectionView.backgroundColor = defaultBackgroundColor
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

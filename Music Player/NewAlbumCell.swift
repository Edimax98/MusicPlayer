//
//  NewAlbumCell.swift
//  Music Player
//
//  Created by Даниил on 10.09.2018.
//  Copyright © 2018 polat. All rights reserved.
//

import UIKit

class NewAlbumCell: UICollectionViewCell {

    @IBOutlet weak var newAlbumCoverImageView: UIImageView!
    
    @IBOutlet weak var albumNameLabel: UILabel!
    @IBOutlet weak var albumAuthorNameLabel: UILabel!
    @IBOutlet weak var albumCoverImageView: UIImageView!
    
    fileprivate let defaultBackgroundColor = UIColor(red: 13 / 255, green: 15 / 255, blue: 22 / 255, alpha: 1)
    static var identifier = "NewAlbumCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        self.albumCoverImageView.layer.cornerRadius = 4
        self.albumCoverImageView.clipsToBounds = true
        self.backgroundColor = defaultBackgroundColor
    }
}

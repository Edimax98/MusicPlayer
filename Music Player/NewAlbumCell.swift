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
    fileprivate let defaultBackgroundColor = UIColor(red: 13 / 255, green: 15 / 255, blue: 22 / 255, alpha: 1)

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = defaultBackgroundColor
    }
}

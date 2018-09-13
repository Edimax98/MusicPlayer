//
//  ClipCell.swift
//  Music Player
//
//  Created by Даниил on 10.09.2018.
//  Copyright © 2018 polat. All rights reserved.
//

import UIKit

class ClipCell: UICollectionViewCell {

    @IBOutlet weak var timeOfClip: UILabel!
    @IBOutlet weak var clipCoverImageView: UIImageView!
    fileprivate let cornerRadius: CGFloat = 7
    fileprivate let defaultBackgroundColor = UIColor(red: 13 / 255, green: 15 / 255, blue: 22 / 255, alpha: 1)

    override func awakeFromNib() {
        super.awakeFromNib()
        clipCoverImageView.layer.cornerRadius = cornerRadius
        clipCoverImageView.layer.masksToBounds = true
        self.backgroundColor = defaultBackgroundColor
    }
}

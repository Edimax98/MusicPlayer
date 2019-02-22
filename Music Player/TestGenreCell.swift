//
//  TestGenreCell.swift
//  Music Player
//
//  Created by Даниил on 21/02/2019.
//  Copyright © 2019 polat. All rights reserved.
//

import UIKit

class TestGenreCell: UICollectionViewCell {

    @IBOutlet weak var backImageView: UIImageView!
    @IBOutlet weak var genreLabel: UILabel!
    
    static var identifier = "\(TestGenreCell.self)"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 16
        contentView.layer.cornerRadius = 16
        backImageView.clipsToBounds = true
        layer.borderWidth = 2
        layer.borderColor = UIColor(red: 182 / 255, green: 149 / 255, blue: 1, alpha: 1).cgColor
    }
}

//
//  PreferedGenreCellCollectionViewCell.swift
//  Music Player
//
//  Created by Даниил Смирнов on 09.09.2018.
//  Copyright © 2018 polat. All rights reserved.
//

import UIKit

class PreferedGenreCell: UICollectionViewCell {

	@IBOutlet weak var preferedGenreLabel: UILabel!
    @IBOutlet weak var preferedGenreImageView: UIImageView!
    
    static var identifier = "PreferedGenreCell"
    private let defaultColor = UIColor(red: 36/255.0, green: 38/255.0, blue: 57/255.0, alpha: 1)
    
	override func awakeFromNib() {
        super.awakeFromNib()
		self.layer.cornerRadius = 15
        self.backgroundColor = defaultColor
    }
}

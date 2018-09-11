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
    
    static var identifier = "PreferedGenreCell"
	
	override func awakeFromNib() {
        super.awakeFromNib()
		self.layer.cornerRadius = 15
    }
}

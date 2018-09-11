//
//  UpperCell.swift
//  Music Player
//
//  Created by Даниил Смирнов on 09.09.2018.
//  Copyright © 2018 polat. All rights reserved.
//

import UIKit

class UpperCell: UITableViewCell {

	@IBOutlet weak var backgroundImage: UIImageView!
	@IBOutlet weak var headphoneImage: UIImageView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var subTitleLabel: UILabel!
    
    static var identifier = "UpperCell"
	
	override func awakeFromNib() {
        super.awakeFromNib()
    }
}

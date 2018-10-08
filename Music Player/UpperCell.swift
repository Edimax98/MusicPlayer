//
//  UpperCell.swift
//  Music Player
//
//  Created by Даниил Смирнов on 09.09.2018.
//  Copyright © 2018 polat. All rights reserved.
//

import UIKit

class UpperCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var backgroundImage: UIImageView!
	@IBOutlet weak var headphoneImage: UIImageView!
	@IBOutlet weak var titleLabel: UILabel!
    
    static var identifier = "UpperCell"
    fileprivate let defaultBackgroundColor = UIColor(red: 13 / 255, green: 15 / 255, blue: 22 / 255, alpha: 1)

	override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        containerView.backgroundColor = defaultBackgroundColor
        titleLabel.text = "Play the moment".localized
    }
}

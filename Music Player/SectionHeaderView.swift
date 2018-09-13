//
//  SectionHeaderView.swift
//  Music Player
//
//  Created by Даниил on 11.09.2018.
//  Copyright © 2018 polat. All rights reserved.
//

import UIKit

class SectionHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var dividerView: UIView!
    @IBOutlet weak var sectionNameLabel: UILabel!
    @IBOutlet weak var sectionIconImageView: UIImageView!
    
    static var identifier = "SectionHeaderView"
    fileprivate let defaultBackgroundColor = UIColor(red: 13 / 255, green: 15 / 255, blue: 22 / 255, alpha: 1)

    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.backgroundColor = defaultBackgroundColor
    }
}

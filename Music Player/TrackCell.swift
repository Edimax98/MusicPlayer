//
//  TrackCell.swift
//  Music Player
//
//  Created by Даниил on 20.09.2018.
//  Copyright © 2018 polat. All rights reserved.
//

import UIKit

class TrackCell: UITableViewCell {
    
    static var identifier = "TrackCell"
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var artistNameLable: UILabel!
    
    fileprivate let imageCornerRadius: CGFloat = 2
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        posterImageView.layer.cornerRadius = imageCornerRadius
        posterImageView.layer.masksToBounds = true
    }
}

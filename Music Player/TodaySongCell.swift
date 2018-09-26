//
//  TodaySongCell.swift
//  Music Player
//
//  Created by Даниил Смирнов on 09.09.2018.
//  Copyright © 2018 polat. All rights reserved.
//

import UIKit

class TodaySongCell: UICollectionViewCell {

	@IBOutlet weak var typeOfPlaylistLabel: UILabel!
	@IBOutlet weak var playlistCoverImageView: UIImageView!
	@IBOutlet weak var infoAboutPlaylistLabel: UILabel!
    
	static var identifier = "TodaySongCell"
    fileprivate let cornerRadius: CGFloat = 7
    fileprivate let defaultBackgroundColor = UIColor(red: 13 / 255, green: 15 / 255, blue: 22 / 255, alpha: 1)
    
	override func awakeFromNib() {
        super.awakeFromNib()
        playlistCoverImageView.layer.cornerRadius = cornerRadius
        self.backgroundColor = defaultBackgroundColor
    }
}

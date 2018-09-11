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
	
    fileprivate let cornerRadius: CGFloat = 7
    
	override func awakeFromNib() {
        super.awakeFromNib()
        
        if playlistCoverImageView != nil && typeOfPlaylistLabel != nil && infoAboutPlaylistLabel != nil {
            playlistCoverImageView.layer.cornerRadius = cornerRadius
            typeOfPlaylistLabel.text = "Type of playlist"
            infoAboutPlaylistLabel.text = "Info about playlist"
        }
    }
}

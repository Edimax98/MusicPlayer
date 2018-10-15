//
//  PlayerViewControllerDelegate.swift
//  Music Player
//
//  Created by Даниил on 08/10/2018.
//  Copyright © 2018 polat. All rights reserved.
//

import Foundation

protocol PlayerViewControllerDelegate: class {
    
    func didPressPlayButton()
    
	func didPressNextButton(completion: @escaping (_ newSong: Song) -> Void)
    
    func didPressPreviousButton(completion: @escaping (_ newSong: Song) -> Void)
    
    func didChangeTime(to newTime: TimeInterval)
    
    func didChangeVolume(to newVolume: Float)
}

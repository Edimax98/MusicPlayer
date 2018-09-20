//
//  LandingPageViewOutput.swift
//  Music Player
//
//  Created by Даниил on 19.09.2018.
//  Copyright © 2018 polat. All rights reserved.
//

import Foundation

protocol LandingPageViewOutputSingleValue: class {
    
    func sendSong(_ song: Song)
}

protocol LandingPageViewOutputMultipleValues: class {

    func sendSongs(_ songs: [Song])
}

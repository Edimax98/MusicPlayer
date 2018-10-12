//
//  ActionHandler.swift
//  Music Player
//
//  Created by Даниил on 11.09.2018.
//  Copyright © 2018 polat. All rights reserved.
//

import Foundation

protocol SongActionHandler: class {
    
    func musicWasSelected(_ song: Song)
}

protocol AlbumsActionHandler: class {
    
    func albumWasSelected(_ album: Album)
}

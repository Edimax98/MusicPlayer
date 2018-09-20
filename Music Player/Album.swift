//
//  Album.swift
//  Music Player
//
//  Created by Даниил on 17.09.2018.
//  Copyright © 2018 polat. All rights reserved.
//

import Foundation
import AlamofireImage

struct Album: Model {
    
    var name: String
    var artistName: String
    var imagePath: String
    var songs: [Song]
    var image: Image?
    
    init(name: String, artistName: String, imagePath: String, songs: [Song]) {
        self.name = name
        self.artistName = artistName
        self.imagePath = imagePath
        self.songs = songs
    }
}

//
//  Song.swift
//  Music Player
//
//  Created by Даниил on 18.09.2018.
//  Copyright © 2018 polat. All rights reserved.
//

import Foundation
import AlamofireImage

struct Song: Equatable, Model {
    var name: String
    var imagePath: String
    var artistName: String
    var duration: UInt
    var albumName: String
    var audioPath: String
    var image: Image?
}

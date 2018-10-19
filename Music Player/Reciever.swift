//
//  Reciever.swift
//  Music Player
//
//  Created by Даниил on 16/10/2018.
//  Copyright © 2018 polat. All rights reserved.
//

import Foundation

protocol Reciever { }

protocol AlbumReceiver: Reciever {
    func receive(model: Album)
}

protocol SongReceiver: Reciever {
    func receive(model: Song)
}

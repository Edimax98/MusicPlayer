//
//  Sender.swift
//  Music Player
//
//  Created by Даниил on 16/10/2018.
//  Copyright © 2018 polat. All rights reserved.
//

import Foundation

protocol Sender {
    
    var recipients: [Reciever] { get }
    
    func send(album: Album)
    
    func send(song: Song)
}

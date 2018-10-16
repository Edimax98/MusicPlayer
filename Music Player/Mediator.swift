//
//  Mediator.swift
//  Music Player
//
//  Created by Даниил on 16/10/2018.
//  Copyright © 2018 polat. All rights reserved.
//

import Foundation

protocol Mediator {
    func add(recipient: ViewReciever)
}

class SongMediator: Sender, Mediator {
    
    typealias MessageType = Song
    typealias ReceiverType = ViewReciever
    
    var recipients: [ViewReciever] = []
    
    func add(recipient: ViewReciever) {
       self.recipients.append(recipient)
    }
    
    func send(message: Song) {
        for recipient in recipients {
            recipient.recieve(message: message)
        }
    }
}

class AlbumMediator: Sender, Mediator {
    
    typealias MessageType = Album
    typealias ReceiverType = ViewReciever
    
    var recipients: [ViewReciever] = []
    
    func add(recipient: ViewReciever) {
        recipients.append(recipient)
    }
    
    func send(message: Album) {
        for recipient in recipients {
            recipient.recieve(message: message)
        }
    }
}

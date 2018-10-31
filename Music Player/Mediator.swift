//
//  Mediator.swift
//  Music Player
//
//  Created by Даниил on 16/10/2018.
//  Copyright © 2018 polat. All rights reserved.
//

import UIKit

class Mediator: Sender {

    var recipients: [Reciever] = []
    
    func removeAllRecipients() {
        recipients.removeAll()
    }
    
    func add(recipient: Reciever) {
       self.recipients.append(recipient)
    }
    
    func denyAccess() {
        for recipient in recipients {
            recipient.accessDenied()
        }
    }
    
    func send(album: Album) {
        for recipient in recipients {
            if let r = recipient as? AlbumReceiver {
                r.receive(model: album)
            }
        }
    }
    
    func send(song: Song) {
        for recipient in recipients {
            if let r = recipient as? SongReceiver {
                r.receive(model: song)
            }
        }
    }
}


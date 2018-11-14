//
//  SongNetworkService.swift
//  Music Player
//
//  Created by Даниил on 18.09.2018.
//  Copyright © 2018 polat. All rights reserved.
//

import Foundation

protocol SongNetworkServiceDelegate: FetchingErrorHandler {
    
    func songNetworkerServiceDidGet(_ songs: [Song])
    
    func songNetworkServiceDidGet(_ songs: [Song], with tags: [String])
}

protocol SongNetworkService: class {
    
    var songNetworkServiceDelegate: SongNetworkServiceDelegate? { get set }
    
    func fetchSongs(_ amount: UInt)
    
    func fetchSong(with tags: [String])
}

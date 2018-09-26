//
//  TodaysPlaylistsNertworkService.swift
//  Music Player
//
//  Created by Даниил on 26/09/2018.
//  Copyright © 2018 polat. All rights reserved.
//

import Foundation

protocol TodaysPlaylistsNetworkServiceDelegate: FetchingErrorHandler {

    func todaysPlaylistNetworkServiceDidGet(_ playlists: [Album])
}

protocol TodaysPlaylistsNetworkService: class {
    
    var todaysPlaylistDelegate: TodaysPlaylistsNetworkServiceDelegate? { get set }
    
    func fetchTodaysPlaylists(for genres: [String], amountOfSongs: Int)
}

//
//  MusicPlayerLandingInteractor.swift
//  Music Player
//
//  Created by Даниил on 18.09.2018.
//  Copyright © 2018 polat. All rights reserved.
//

import Foundation

class MusicPlayerLandingInteractor {
    
    fileprivate var networkService: NetworkService
    fileprivate var songNetworkService: SongNetworkService
    
    init(_ networkService: NetworkService) {
        
        self.networkService = networkService
        self.songNetworkService = networkService
        self.songNetworkService.songNetworkServiceDelegate = self
    }
    
    func fetchSong(by id: String) {
        
    }
}

// MARK: - SongNetworkServiceDelegate
extension MusicPlayerLandingInteractor: SongNetworkServiceDelegate {
    
    func songNetworkerServiceDidGet(_ songs: [Song]) {
        
    }
    
    func fetchingEndedWithError(_ error: Error) {
        
    }
}

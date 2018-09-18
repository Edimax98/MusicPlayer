//
//  MusicPlayerLandingPageInteractor.swift
//  Music Player
//
//  Created by Даниил on 18.09.2018.
//  Copyright © 2018 polat. All rights reserved.
//

import Foundation

class MusicPlayerLandingPageInteractor {
    
    weak var output: MusicPlayerInteractorOutput?
    fileprivate var networkService: NetworkService
    fileprivate var songNetworkService: SongNetworkService
    
    init(_ networkService: NetworkService) {
        self.networkService = networkService
        self.songNetworkService = networkService
        self.songNetworkService.songNetworkServiceDelegate = self
    }
    
    func fetchSong(_ amount: UInt) {
        networkService.fetchSongs(10)
    }
}

// MARK: - SongNetworkServiceDelegate
extension MusicPlayerLandingPageInteractor: SongNetworkServiceDelegate {
    
    func songNetworkerServiceDidGet(_ songs: [Song]) {
        DispatchQueue.main.async {
         self.output?.sendSongs(songs)
        }
    }
    
    func fetchingEndedWithError(_ error: Error) {
        
    }
}

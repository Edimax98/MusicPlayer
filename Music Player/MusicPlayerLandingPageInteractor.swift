 //
//  MusicPlayerLandingPageInteractor.swift
//  Music Player
//
//  Created by Даниил on 18.09.2018.
//  Copyright © 2018 polat. All rights reserved.
//

import Foundation

class MusicPlayerLandingPageInteractor {
    
    weak var songsOutput: SongsInteractorOutput?
    weak var albumsOutput: AlbumInteractorOutput?
    fileprivate var networkService: NetworkService
    fileprivate var songNetworkService: SongNetworkService
    fileprivate var albumNetworkService: AlbumNetworkService
    
    init(_ networkService: NetworkService) {
        self.networkService = networkService
        self.songNetworkService = networkService
        self.albumNetworkService = networkService
        self.songNetworkService.songNetworkServiceDelegate = self
        self.albumNetworkService.albumNetworkDelegate = self
    }
    
    func fetchSong(_ amount: UInt) {
        networkService.fetchSongs(10)
    }
    
    func fetchAlbums(_ amount: UInt) {
        networkService.fetchAlbums(amount)
    }
}

// MARK: - SongNetworkServiceDelegate
extension MusicPlayerLandingPageInteractor: SongNetworkServiceDelegate {
    
    func songNetworkerServiceDidGet(_ songs: [Song]) {
        DispatchQueue.main.async {
         self.songsOutput?.sendSongs(songs)
        }
    }
    
    func fetchingEndedWithError(_ error: Error) {
        
    }
}

// MARK: - AlbumNetworkServiceDelegate
extension MusicPlayerLandingPageInteractor: AlbumNetworkServiceDelegate {
    
    func albumNetworkServiceDidGet(_ albums: [Album]) {
        
        DispatchQueue.main.async {
            self.albumsOutput?.sendAlbums(albums)
        }
    }
}

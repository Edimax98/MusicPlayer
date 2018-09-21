 //
 //  MusicPlayerLandingPageInteractor.swift
 //  Music Player
 //
 //  Created by Даниил on 18.09.2018.
 //  Copyright © 2018 polat. All rights reserved.
 //
 
 import Foundation
 import AlamofireImage
 
 class MusicPlayerLandingPageInteractor {
    
    weak var songsOutput: SongsInteractorOutput?
    weak var albumsOutput: AlbumInteractorOutput?
    
    fileprivate var networkService: NetworkService
    fileprivate var songNetworkService: SongNetworkService
    fileprivate var albumNetworkService: AlbumNetworkService
    fileprivate var imageFetcherNetworkService: ImageFetchNetworkService
    
    fileprivate var songs = [Song]()
    fileprivate var albums = [Album]()
    
    init(_ networkService: NetworkService) {
        self.networkService = networkService
        self.songNetworkService = networkService
        self.albumNetworkService = networkService
        self.imageFetcherNetworkService = networkService
        self.songNetworkService.songNetworkServiceDelegate = self
        self.albumNetworkService.albumNetworkDelegate = self
        self.imageFetcherNetworkService.imageFetcherDelegate = self
    }
    
    private func calculateDateForNewRealeases(with timeOffset: DateComponents) -> Date {
        
        let currentDate = Date()
        guard let futureDate = Calendar.current.date(byAdding: timeOffset, to: currentDate) else {
            print("Could not add date")
            return Date()
        }
        
        return futureDate
    }
    
    fileprivate func transformDateToString(_ date: Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let resultOfTransformation = dateFormatter.string(from: date)
        
        return resultOfTransformation
    }
    
    fileprivate func getImagePaths(from songs: [Song]) -> [String] {
        return songs.map { $0.imagePath }
    }
    
    fileprivate func getImagePaths(from albums: [Album]) -> [String] {
        return albums.map { $0.imagePath }
    }
    
    fileprivate func setImagesForAlbums(_ images: [Image]) {
        
        var i = 0
        while images.count - 1 >= i {
            albums[i].image = images[i]
            i += 1
        }
    }
    
    fileprivate func setImagesForSongs(_ images: [Image])  {
        
        var i = 0
        while images.count - 1 >= i {
            songs[i].image = images[i]
            i += 1
        }
    }
    
    func fetchSong(_ amount: UInt) {
        networkService.fetchSongs(10)
    }
    
    func fetchAlbums(_ amount: UInt) {
        networkService.fetchAlbums(amount)
    }
    
    func fetchNewAlbums(amount: UInt) {
        
        var distanceBetweenDates = DateComponents()
        distanceBetweenDates.month = -12
        let startDate = calculateDateForNewRealeases(with: distanceBetweenDates)
        let startDateString = transformDateToString(startDate)
        let endDateString = transformDateToString(Date())
        
        networkService.fetchAlbums(amount: amount, between: startDateString, and: endDateString)
    }
 }
 
 // MARK: - SongNetworkServiceDelegate
 extension MusicPlayerLandingPageInteractor: SongNetworkServiceDelegate {
    
    func songNetworkerServiceDidGet(_ songs: [Song]) {
        self.songs = songs
        let paths = getImagePaths(from: songs)
        networkService.fetchImages(from: paths, for: .song)
    }
    
    func fetchingEndedWithError(_ error: Error) {
        
    }
 }
 
 // MARK: - AlbumNetworkServiceDelegate
 extension MusicPlayerLandingPageInteractor: AlbumNetworkServiceDelegate {
    
    func albumNetworkServiceDidGet(_ albums: [Album]) {
        self.albums = albums
        let paths = getImagePaths(from: songs)
        networkService.fetchImages(from: paths, for: .album)
    }
 }
 
 // MARK: - ImageFetchNetworkServiceDelegate
 extension MusicPlayerLandingPageInteractor: ImageFetchNetworkServiceDelegate {
    
    func imageFetchNetworkSeriviceDidGet(_ images: [Image], with modelType: ModelType) {
        
        DispatchQueue.main.async {
            switch modelType {
            case .song:
                self.setImagesForSongs(images)
                self.songsOutput?.sendSongs(self.songs)
            case .album:
                self.setImagesForAlbums(images)
                self.albumsOutput?.sendAlbums(self.albums)
            }
        }
    }
 }
 
 

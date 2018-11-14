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
    weak var playlistOutput: PlaylistInteractorOutput?
    
    fileprivate var networkService: NetworkService
    fileprivate var songNetworkService: SongNetworkService
    fileprivate var albumNetworkService: AlbumNetworkService
    fileprivate var imageFetcherNetworkService: ImageFetchNetworkService
    fileprivate var todayPlaylistNetworkService: TodaysPlaylistsNetworkService
    
    fileprivate let genres = ["Indie Rock", "Deep House","Hip-Hop", "Jazz", "Country",
                        "Art Pop", "Rock", "Classical", "Trap", "Pop", "RNB",
                        "Modern Rock", "Chill", "Bass Trap", "Dance Pop",
                        "Blues","Pop Rock", "Bass Trap",
                        "Beats","EDM", "DeepHouse", "Trance", "Techno"]
    
    fileprivate var songs = [Song]()
    fileprivate var albums = [Album]()
    fileprivate var playlists = [Album]()
    fileprivate var imagesInsidePlaylists: [[Image]]?
    
    init(_ networkService: NetworkService) {
        self.networkService = networkService
        self.songNetworkService = networkService
        self.albumNetworkService = networkService
        self.imageFetcherNetworkService = networkService
        self.todayPlaylistNetworkService = networkService
        self.songNetworkService.songNetworkServiceDelegate = self
        self.albumNetworkService.albumNetworkDelegate = self
        self.imageFetcherNetworkService.imageFetcherDelegate = self
        self.todayPlaylistNetworkService.todaysPlaylistDelegate = self
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
    
    fileprivate func getImagePathsForSongs(in playlists: [Album]) -> [[String]] {
        
        var paths = [[String]]()
        
        for playlist in playlists {
            paths.append(getImagePaths(from: playlist.songs))
         }
        
        return paths
    }
    
    fileprivate func setImagesForAlbums(_ images: [String:Image]) {
        
        var i = 0
        
        while images.count - 1 >= i {
            if images.keys.contains(where: { (url) -> Bool in albums[i].imagePath == url }) {
                albums[i].image = images[albums[i].imagePath]
            }
            i += 1
        }
    }
    
    fileprivate func setImagesForSongs(_ images: [String:Image])  {
        
        var i = 0
        
        while images.count - 1 >= i {
            if images.keys.contains(where: { (url) -> Bool in songs[i].imagePath == url }) {
                songs[i].image = images[songs[i].imagePath]
            }
            i += 1
        }
    }

    fileprivate func setImagesForSongsInsidePlaylist(_ nestedImages: [[String:Image]]) {
        
        var i = 0
        var j = 0
        
        while i <= nestedImages.count - 1 {
            j = 0
            while j <= nestedImages[i].count - 1 {
                if playlists.count - 1 < i { return }
                if playlists[i].songs.count - 1 < j { return }
                if nestedImages[i].keys.contains(where: { (url) -> Bool in playlists[i].songs[j].imagePath == url }) {
                    playlists[i].songs[j].image = nestedImages[i][playlists[i].songs[j].imagePath]
                }
                j += 1
            }
            i += 1
        }
    }
    
    fileprivate func getRandomGenres(from genres: [String], with amount: Int) -> [String] {
        
        var result = [String]()
        var i = 0
        
        while i <= amount {
            let randomIndex = Int(arc4random_uniform(UInt32(genres.count)))
            if !result.contains(genres[randomIndex]) {
                result.append(genres[randomIndex])
            }
            i += 1
        }
        return result
    }
    
    func fetchSong(_ amount: UInt) {
        networkService.fetchSong(with: ["happy"])
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
    
    func fetchTodaysPlaylists(amountOfSongs: Int) {
        let randomGenres = getRandomGenres(from: self.genres, with: 5)
        networkService.fetchTodaysPlaylists(for: randomGenres, amountOfSongs: amountOfSongs)
    }
 }
 
 // MARK: - SongNetworkServiceDelegate
 extension MusicPlayerLandingPageInteractor: SongNetworkServiceDelegate {
    
    func songNetworkServiceDidGet(_ songs: [Song], with tags: [String]) {
        
        self.songs = songs
        let paths = getImagePaths(from: songs)
        networkService.fetchImages(from: paths, for: .song)
    }
    
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
        let paths = getImagePaths(from: albums)
        networkService.fetchImages(from: paths, for: .album)
    }
 }
 
 // MARK: - ImageFetchNetworkServiceDelegate
 extension MusicPlayerLandingPageInteractor: ImageFetchNetworkServiceDelegate {
    
    func imageFetchNetworkSeriviceDidGet(_ nestedImages: [[String:Image]]) {
        
        DispatchQueue.main.async {
            self.setImagesForSongsInsidePlaylist(nestedImages)
            self.playlistOutput?.sendPlaylist(self.playlists)
        }
    }
    
    func imageFetchNetworkSeriviceDidGet(_ images: [String:Image], with modelType: ModelType) {
        
        DispatchQueue.main.async {
            switch modelType {
            case .song:
                self.setImagesForSongs(images)
                self.songsOutput?.sendSongs(self.songs)
            case .album:
                self.setImagesForAlbums(images)
                self.albumsOutput?.sendAlbums(self.albums)
            default:
                break
            }
        }
    }
 }
 
// MARK: - TodaysPlaylistsNetworkServiceDelegate
 extension MusicPlayerLandingPageInteractor: TodaysPlaylistsNetworkServiceDelegate {
    
    func todaysPlaylistNetworkServiceDidGet(_ playlists: [Album]) {
        self.playlists = playlists
        let paths = getImagePathsForSongs(in: playlists)
        networkService.fetchNestedImages(from: paths)
    }
 }
 
 
 
 

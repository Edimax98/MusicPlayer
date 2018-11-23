//
//  NetworkService.swift
//  Music Player
//
//  Created by Даниил on 18.09.2018.
//  Copyright © 2018 polat. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage
import SwiftyJSON

class NetworkService {
    
    private let apiKey: String
    fileprivate var fetchingQueue = DispatchQueue.global(qos: .utility)
    
    weak var songNetworkServiceDelegate: SongNetworkServiceDelegate?
    weak var albumNetworkDelegate: AlbumNetworkServiceDelegate?
    weak var imageFetcherDelegate: ImageFetchNetworkServiceDelegate?
    weak var todaysPlaylistDelegate: TodaysPlaylistsNetworkServiceDelegate?
    
    init() {
        apiKey = "af79529f"
    }
}

// MARK: - SongNetworkService
extension NetworkService: SongNetworkService {
    
    private func getSongs(from rawDataResponse: DataResponse<Any>) -> [Song]? {
        
        guard let responseValue = rawDataResponse.result.value else {
            print("Song raw json is nil")
            return nil
        }
        
        let json = JSON(responseValue)["results"]

        let songs = json.array?.map { jsonArr -> Song in
            Song(name: jsonArr["name"].stringValue, imagePath: jsonArr["image"].stringValue, artistName: jsonArr["artist_name"].stringValue, duration: jsonArr["duration"].uIntValue, albumName: jsonArr["album_name"].stringValue, audioPath: jsonArr["audio"].stringValue, image: nil)
        }
        
        guard let songsToReturn = songs else {
            print("Songs are nil after being parsed")
            return nil
        }
        
        return songsToReturn
    }
    
    func fetchSong(with tags: [String]) {
     
        request(SongApi.baseUrl, method: .get, parameters: SongApi.themeSongs(themes: tags).parameters, encoding: URLEncoding.default, headers: nil)
            .response(queue: fetchingQueue, responseSerializer: DataRequest.jsonResponseSerializer()) { (response) in
                guard let songs = self.getSongs(from: response) else { return }
                self.songNetworkServiceDelegate?.songNetworkServiceDidGet(songs, with: tags)
        }
    }
    
    func fetchSongs(_ amount: UInt) {
        
        let parameters = SongApi.topSongs(popularityPeriod: "popularity_month").parameters
        
        request(SongApi.baseUrl, method: .get, parameters: parameters, encoding: URLEncoding(), headers: nil)
            .validate()
            .response(queue: fetchingQueue, responseSerializer: DataRequest.jsonResponseSerializer()) { (response) in
                guard let songs = self.getSongs(from: response) else { return }
                self.songNetworkServiceDelegate?.songNetworkerServiceDidGet(songs)
        }
    }
}

// MARK: - AlbumNetworkService
extension NetworkService: AlbumNetworkService {
    
    func fetchAlbums(_ amount: UInt) {
        
        let fetchingQueue = DispatchQueue.global(qos: .utility)
        let parameters = AlbumApi.bunchOfAlbums(amount: amount).parameters
        
        request(AlbumApi.baseUrl, method: .get, parameters: parameters, encoding: URLEncoding(), headers: nil)
            .response(queue: fetchingQueue, responseSerializer: DataRequest.jsonResponseSerializer()) { (response) in
                
                guard let responseValue = response.result.value else {
                    print("Album raw json is nil")
                    return
                }
                
                let json = JSON(responseValue)["results"]
                
                let albums = json.array?.map { jsonArr -> Album in
                    Album(name: jsonArr["name"].stringValue, artistName: jsonArr["artist_name"].stringValue, imagePath: jsonArr["image"].stringValue,
                          songs: jsonArr["tracks"].array!.map { jsonTrackArr -> Song in
                            Song(name: jsonTrackArr["name"].stringValue, imagePath: jsonTrackArr["image"].stringValue, artistName: jsonTrackArr["artist_name"].stringValue,
                                 duration: jsonTrackArr["duration"].uIntValue, albumName: jsonTrackArr["album_name"].stringValue, audioPath: jsonTrackArr["audio"].stringValue, image: nil)
                        }
                    )
                }
                
                guard let albumsToReturn = albums else {
                    print("Albums are nil after being parsed")
                    return
                }
                self.albumNetworkDelegate?.albumNetworkServiceDidGet(albumsToReturn)
        }
    }
    
    
    func fetchAlbums(amount: UInt, between startDate: String, and endDate: String) {
        
        let fetchingQueue = DispatchQueue.global(qos: .utility)
        let parameters = AlbumApi.newReleases(amount: amount, startDate: startDate, endDate: endDate).parameters
        
        request(AlbumApi.baseUrl, method: .get, parameters: parameters, encoding: URLEncoding(), headers: nil)
            .response(queue: fetchingQueue, responseSerializer: DataRequest.jsonResponseSerializer()) { (response) in
                
                guard let responseValue = response.result.value else {
                    print("Album raw json is nil")
                    return
                }
                
                let json = JSON(responseValue)["results"]
                
                let albums = json.array?.map { jsonArr -> Album in
                    Album(name: jsonArr["name"].stringValue, artistName: jsonArr["artist_name"].stringValue, imagePath: jsonArr["image"].stringValue,
                          songs: jsonArr["tracks"].array!.map { jsonTrackArr -> Song in
                            Song(name: jsonTrackArr["name"].stringValue, imagePath: jsonTrackArr["image"].stringValue, artistName: jsonArr["artist_name"].stringValue,
                                 duration: jsonTrackArr["duration"].uIntValue, albumName: jsonArr["name"].stringValue, audioPath: jsonTrackArr["audio"].stringValue, image: nil)
                        }
                    )
                }
                
                guard let albumToReturn = albums else {
                    print("Album is nil after being parsed")
                    return
                }
                self.albumNetworkDelegate?.albumNetworkServiceDidGet(albumToReturn)
        }
    }
}

// MARK: - ImageFetchNetworkService
extension NetworkService: ImageFetchNetworkService {
    
    func fetchNestedImages(from nestedUrls: [[String]]) {
        
        let fetchingQueue = DispatchQueue.global(qos: .utility)
        let group = DispatchGroup()
        let outerGroup = DispatchGroup()
        var nestedImages = [[String:Image]]()
        
        for urls in nestedUrls {
            var images = [String:Image]()
            outerGroup.enter()
            for url in urls {
                group.enter()
                let block = DispatchWorkItem(flags: .inheritQoS) {
                    request(url, method: .get, parameters: nil, encoding: URLEncoding(), headers: nil).responseImage { response in
                        
                        guard let image = response.result.value else {
                            print("Image is nil")
                            return
                        }
                        images[url] = image
                        group.leave()
                    }
                }
                fetchingQueue.async(execute: block)
            }
            group.notify(queue: .main) {
                nestedImages.append(images)
                outerGroup.leave()
            }
        }
        outerGroup.notify(queue: .main) {
            self.imageFetcherDelegate?.imageFetchNetworkSeriviceDidGet(nestedImages)
        }
    }
    
    func fetchImages(from urls: [String], for modelType: ModelType, completion: @escaping ([String : Image]) -> ()) {
        
        let fetchingQueue = DispatchQueue.global(qos: .utility)
        let group = DispatchGroup()
        var images = [String:Image]()
        
        for url in urls {
            group.enter()
            let block = DispatchWorkItem(flags: .inheritQoS) {
                request(url, method: .get, parameters: nil, encoding: URLEncoding(), headers: nil).responseImage { response in
                    
                    guard let image = response.result.value else {
                        print("Image is nil")
                        return
                    }
                    images[url] = image
                    group.leave()
                }
            }
            fetchingQueue.async(execute: block)
        }
        group.notify(queue: .main) {
            completion(images)
        }
    }
}

// MARK: - TodaysPlaylistsNetworkService
extension NetworkService: TodaysPlaylistsNetworkService {
    
    func fetchTodaysPlaylists(for genres: [String], amountOfSongs: Int) {
        
        let fetchingQueue = DispatchQueue.global(qos: .utility)
        let group = DispatchGroup()
        var playlists = [Album]()
        
        for genre in genres {
            group.enter()
            let parameters = TodayPlaylistApi.todayPlaylist(genre: genre, amountOfSongs: amountOfSongs).parameters
            
            let block = DispatchWorkItem(flags: .inheritQoS) {
                request(TodayPlaylistApi.baseUrl, method: .get, parameters: parameters, encoding: URLEncoding(), headers: nil).responseJSON { response in
                    
                    guard let responseValue = response.result.value else {
                        print("Today playlist raw json is nil")
                        return
                    }
                    
                    let json = JSON(responseValue)["results"]
                    
                    let todaysPlaylist = Album(name: genre, artistName: "Your friend", imagePath: "", songs: (json.array?.map { jsonArr -> Song in
                        Song(name: jsonArr["name"].stringValue, imagePath: jsonArr["image"].stringValue, artistName: jsonArr["artist_name"].stringValue,
                             duration: jsonArr["duration"].uIntValue, albumName: genre, audioPath: jsonArr["audio"].stringValue, image: nil)
                        })!)
                    
                    playlists.append(todaysPlaylist)
                    group.leave()
                }
            }
            fetchingQueue.async(execute: block)
        }
        group.notify(queue: .main) {
            self.todaysPlaylistDelegate?.todaysPlaylistNetworkServiceDidGet(playlists)
        }
    }
}


























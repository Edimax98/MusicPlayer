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
        apiKey = "88dda971"
    }
}

// MARK: - SongNetworkService
extension NetworkService: SongNetworkService {
    
    private func fetchImages(from urls: [String], completionHandler: @escaping ([Image]) -> Void) {
        
        var images = [Image]()
        
        let workItem = DispatchWorkItem {
            for url in urls {
                request(url, method: .get, parameters: nil, encoding: URLEncoding(), headers: nil).responseImage { (response) in
                    if let image = response.result.value {
                        images.append(image)
                    } else {
                        print("image is nil")
                    }
                }
            }
        }
        
        DispatchQueue.global().async(execute: workItem)
        
        workItem.notify(queue: .main) {
            completionHandler(images)
        }
    }
    
    private func setImages(for songs: inout [Song], with images: [Image]) {
        
        var i = 0
        while (i <= songs.count - 1) {
            songs[i].image = images[i]
            i += 1
        }
    }
    
    func fetchSongs(_ amount: UInt) {
        
        request("https://api.jamendo.com/v3.0/tracks/?client_id=88dda971&limit=10", method: .get, parameters: nil, encoding: URLEncoding(), headers: nil)
            .validate()
            .response(queue: fetchingQueue, responseSerializer: DataRequest.jsonResponseSerializer()) { (response) in
                
                guard let responseValue = response.result.value else {
                    print("Song raw json is nil")
                    return
                }
                
                let json = JSON(responseValue)["results"]
                
                let songs = json.array?.map { jsonArr -> Song in
                    Song(name: jsonArr["name"].stringValue, imagePath: jsonArr["image"].stringValue, artistName: jsonArr["artist_name"].stringValue, duration: jsonArr["duration"].uIntValue, albumName: jsonArr["album_name"].stringValue, audioPath: jsonArr["audio"].stringValue, image: nil)
                }
                
                guard let songsToReturn = songs else {
                    print("Songs are nil after being parsed")
                    return
                }
                
                self.songNetworkServiceDelegate?.songNetworkerServiceDidGet(songsToReturn)
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
    
    func fetchImages(from urls: [String], for modelType: ModelType) {
        
        let fetchingQueue = DispatchQueue.global(qos: .utility)
        let group = DispatchGroup()
        var images = [Image]()
        
        for url in urls {
            group.enter()
            let block = DispatchWorkItem(flags: .inheritQoS) {
                request(url, method: .get, parameters: nil, encoding: URLEncoding(), headers: nil).responseImage { response in
                    
                    guard let image = response.result.value else {
                        print("Image is nil")
                        return
                    }
                    images.append(image)
                    group.leave()
                }
            }
            fetchingQueue.async(execute: block)
        }
        group.notify(queue: .main) {
            self.imageFetcherDelegate?.imageFetchNetworkSeriviceDidGet(images, with: modelType)
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
                    
                    let todaysPlaylist = Album(name: genre, artistName: "Ur friend", imagePath: "", songs: (json.array?.map { jsonArr -> Song in
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


























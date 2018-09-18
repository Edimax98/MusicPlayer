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
    
    var songNetworkServiceDelegate: SongNetworkServiceDelegate?
    
    init() {
        apiKey = "88dda971"
    }
}

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
                    Song(name: jsonArr["name"].stringValue, imagePath: jsonArr["image"].stringValue, artistName: jsonArr["artist_name"].stringValue, duration: jsonArr["duration"].uIntValue, image: nil)
                }
                
                guard var songsToReturn = songs else {
                    print("Songs are nil after being parsed")
                    return
                }
                
                self.songNetworkServiceDelegate?.songNetworkerServiceDidGet(songsToReturn)
        }
    }
}








//
//  NetworkService.swift
//  Music Player
//
//  Created by Даниил on 18.09.2018.
//  Copyright © 2018 polat. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class NetworkService {
    
    private let apiKey: String
    
    var songNetworkServiceDelegate: SongNetworkServiceDelegate?
    
    init() {
        apiKey = "88dda971"
    }
}

extension NetworkService: SongNetworkService {
    
    func fetchSongs() {
        
        let fetchingQueue = DispatchQueue.global(qos: .utility)
        
        request("https://api.jamendo.com/v3.0/tracks/?client_id=88dda971&id=128307", method: .get, parameters: nil, encoding: URLEncoding(), headers: nil)
            .validate()
            .response(queue: fetchingQueue, responseSerializer: DataRequest.jsonResponseSerializer()) { (response) in
                
                guard let responseValue = response.result.value else {
                    print("Song raw json is nil")
                    return
                }
                
                let json = JSON(responseValue)["results"][0]
                let song = Song(name: json["name"].stringValue, image: json["image"].stringValue, artistName: json["artist_name"].stringValue, duration: json["duration"].uIntValue)
                self.songNetworkServiceDelegate?.songNetworkerServiceDidGet([song])
        }
    }
}

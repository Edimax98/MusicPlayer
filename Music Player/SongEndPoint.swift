//
//  SongEndPoint.swift
//  Music Player
//
//  Created by Даниил on 14/11/2018.
//  Copyright © 2018 polat. All rights reserved.
//

import Foundation

enum SongApi {
    case topSongs(popularityPeriod: String)
    case themeSongs(themes: [String])
}

extension SongApi: EndPointType {
    
    static var baseUrl: String {
        return "https://api.jamendo.com/v3.0/tracks/?"
    }
    
    var parameters: [String : Any] {
        switch self {
        case .topSongs(let popularityPeriod):
            return ["client_id":"af79529f", "limit":10, "order":popularityPeriod]
        case .themeSongs(let themes):
            return ["client_id":"af79529f", "limit":10, "tags":themes]
        }
    }
}

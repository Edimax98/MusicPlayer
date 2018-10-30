//
//  TodayPlaylistEndPoint.swift
//  Music Player
//
//  Created by Даниил on 26/09/2018.
//  Copyright © 2018 polat. All rights reserved.
//

import Foundation

fileprivate let genresDivider = "+"

enum TodayPlaylistApi {
    case todayPlaylist(genre: String, amountOfSongs: Int)
    
    fileprivate func prepareQuery(from genres: [String]) -> String {
        
        var queryString = ""
        
        for genre in genres {
            queryString += genre + genresDivider
        }
        
        return queryString
    }
}

// MARK: - EndPointType
extension TodayPlaylistApi: EndPointType {
    
    static var baseUrl: String {
        return "https://api.jamendo.com/v3.0/tracks?client_id=af79529f"
    }
    
    var parameters: [String : Any] {
        switch self {
        case .todayPlaylist(let genre, let amountOfSongs):
            return ["tags":genre,"limit":amountOfSongs]
        }
    }
}

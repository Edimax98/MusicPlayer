//
//  AlbumEndPoint.swift
//  Music Player
//
//  Created by Даниил on 20.09.2018.
//  Copyright © 2018 polat. All rights reserved.
//

import Foundation

fileprivate let dividerForDate = "_"
fileprivate let productionApiKey = "af79529f"
fileprivate let testApiKey = "aa06c755"

enum AlbumApi {
    case newReleases(amount: UInt, startDate: String, endDate: String)
    case bunchOfAlbums(amount: UInt)
}

extension AlbumApi: EndPointType {
    
   static var baseUrl: String {
        return "https://api.jamendo.com/v3.0/albums/tracks/?"
    }
    
    var parameters: [String : Any] {
        switch self {
        case .newReleases(let amount, let startDate, let endDate):
            return ["client_id":productionApiKey,"limit":amount,"datebetween":startDate + dividerForDate + endDate]
        case .bunchOfAlbums(let amount):
            return ["client_id":productionApiKey,"limit":amount]
        }
    }
}

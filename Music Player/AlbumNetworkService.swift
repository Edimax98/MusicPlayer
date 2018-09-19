//
//  AlbumNetworkService.swift
//  Music Player
//
//  Created by Даниил on 19.09.2018.
//  Copyright © 2018 polat. All rights reserved.
//

import Foundation

protocol AlbumNetworkServiceDelegate: FetchingErrorHandler {
    
    func albumNetworkServiceDidGet(_ albums: [Album])
}

protocol AlbumNetworkService: class {
    
    var albumNetworkDelegate: AlbumNetworkServiceDelegate? { get set }
    
    func fetchAlbums(_ amount: UInt)
}

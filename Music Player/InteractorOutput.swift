//
//  MusicPlayerInteractorOutput.swift
//  Music Player
//
//  Created by Даниил on 18.09.2018.
//  Copyright © 2018 polat. All rights reserved.
//

import Foundation

protocol SongsInteractorOutput: class {
    
    func sendSongs(_ songs: [Song])
}

protocol AlbumInteractorOutput: class {
    
    func sendAlbums(_ albums: [Album])
}

protocol ThemePlaylistInteractorOutput: class {
    
    func sendPlaylist(_ playlists: [Album], theme: String)
}

protocol PlaylistInteractorOutput: class {
    
    func sendPlaylist(_ playlists: [Album])
}

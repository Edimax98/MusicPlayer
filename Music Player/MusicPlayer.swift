//
//  MusicPlayer.swift
//  Music Player
//
//  Created by Даниил on 08/10/2018.
//  Copyright © 2018 polat. All rights reserved.
//

import Foundation

protocol MusicPlayerDelegate: class {
    
    func playbackStateDidChange(_ playbackState: PlayerPlaybackState)
    
    func songDidUpdate(_ song: Song?)
    
    func albumDidUpdate(_ album: Album?)
}

class MusicPlayer {
    
    weak var delegate: MusicPlayerDelegate?
    let player = Player.shared
    
    private(set) var song: Song?
    private(set) var album: Album?
    
    init() {
        player.delegate = self
    }
    
    func resetMusicPlayer() {
        song = nil
        album = nil
        player.itemURL = nil
    }
    
    func updateSong(_ song: Song) {
        
        if self.song == nil {
            self.song = song
        }
        delegate?.songDidUpdate(song)
    }
    
    func updateAlbum(_ album: Album) {
        
        if self.album == nil {
            self.album = album
        }
        delegate?.albumDidUpdate(album)
    }
}

// MARK: - PlayerDelegate
extension MusicPlayer: PlayerDelegate {
    
    func player(_ player: Player, playerStateDidChanged state: PlayerState) {
        
    }
    
    func player(_ player: Player, playerPlaybackStateDidChange state: PlayerPlaybackState) {
    
    }
    
    func player(_ player: Player, itemUrlDidChange url: URL?) {
        
    }
}

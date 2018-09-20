//
//  SongsDataSource.swift
//  Music Player
//
//  Created by Даниил on 20.09.2018.
//  Copyright © 2018 polat. All rights reserved.
//

import UIKit
import AlamofireImage
import Alamofire

class SongsDataSource: NSObject {
    
    var songs = [Song]()
    
    func setSongs(_ songs: [Song]) {
        self.songs = songs
    }
    
    func getSongs() -> [Song] {
        return self.songs
    }
}

// MARK: - UITableViewDataSource
extension SongsDataSource: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let song = songs[indexPath.row]
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TrackCell.identifier, for: indexPath) as? TrackCell else {
            print("Could not dequeue cell")
            return UITableViewCell()
        }
        
        cell.posterImageView?.image = song.image
        cell.artistNameLable.text = song.artistName
        cell.songNameLabel.text = song.name
        
        return cell
    }
}

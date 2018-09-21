//
//  MusicListViewController.swift
//  Music Player
//
//  Created by Даниил on 20.09.2018.
//  Copyright © 2018 polat. All rights reserved.
//

import UIKit

class MusicListViewController: UIViewController {

    @IBOutlet weak var musicTableView: UITableView!
    fileprivate let dataSource = SongsDataSource()
    fileprivate weak var multipleDataOutput: LandingPageViewOutputMultipleValues?
    fileprivate weak var songActionHandler: SongsActionHandler?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        musicTableView.dataSource = dataSource
        musicTableView.delegate = self
        musicTableView.register(UINib(nibName: "TrackCell", bundle: nil), forCellReuseIdentifier: TrackCell.identifier)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "albumTrackSelected" {
            guard let distinationVc = segue.destination as? PlayerViewController else {
                print("Could not cast destination")
                return
            }
            multipleDataOutput = distinationVc
            songActionHandler = distinationVc
            multipleDataOutput?.sendSongs(dataSource.getSongs())
        }
    }
}

// MARK: - UITableViewDelegate
extension MusicListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let song = dataSource.getSongs()[indexPath.row]
        performSegue(withIdentifier: "albumTrackSelected", sender: self)
        songActionHandler?.musicWasSelected(song)
    }
}

// MARK: - LandingPageViewOutputMultipleValues
extension MusicListViewController: LandingPageViewOutputMultipleValues {
    
    func sendSongs(_ songs: [Song]) {
        dataSource.setSongs(songs)
        musicTableView.reloadData()
    }
}

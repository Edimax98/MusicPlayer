//
//  MusicPlayerLandingPage.swift
//  Music Player
//
//  Created by Даниил Смирнов on 09.09.2018.
//  Copyright © 2018 polat. All rights reserved.
//

import UIKit
import AVFoundation

class MusicPlayerLandingPage: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nowPlayingSongCover: UIImageView!
    @IBOutlet weak var nowPlayingSongName: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    fileprivate var audioPlayer = AVPlayer()
    fileprivate var playerItems = [AVPlayerItem]()

    fileprivate var tracks = [Song]()
    fileprivate var shouldBePlayedFromBegining = false
    fileprivate var currentAudioIndex = 0
    
    fileprivate var isPlaying: Bool {
        get {
            return audioPlayer.rate != 0
        }
    }
    
    fileprivate var interactor: MusicPlayerLandingPageInteractor?
    fileprivate weak var outputSingleValue: LandingPageViewOutputSingleValue?
    fileprivate weak var outputMultipleValue: LandingPageViewOutputMultipleValues?
    fileprivate weak var songActionHandler: SongsActionHandler?
    fileprivate weak var albumActionHandler: AlbumsActionHandler?
    fileprivate let countOfRowsInSection = 1
    fileprivate let countOfSection = 5
    fileprivate var dataSource = [HeaderData]()
    fileprivate let headerSize: CGFloat = 60
    fileprivate let defaultBackgroundColor = UIColor(red: 13 / 255, green: 15 / 255, blue: 22 / 255, alpha: 1)
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: self.audioPlayer.currentItem)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = defaultBackgroundColor
        nowPlayingSongCover.layer.cornerRadius = 2
        let networkService = NetworkService()
        interactor = MusicPlayerLandingPageInteractor(networkService)
        registerCells(for: tableView)
        fillDataSource()
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(notification:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.audioPlayer.currentItem)
        
        let audioSession = AVAudioSession()
        do {
            try audioSession.setActive(true)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    @objc func playerItemDidReachEnd(notification: Notification) {
        print(notification.description)
        playNext()
    }
    
    @IBAction func nowPlayingViewTapped(_ sender: Any) {
        
    }
    
    @IBAction func playNowPlayingSongButtonPressed(_ sender: Any) {
        
        if tracks.isEmpty {
            return
        }
        
        if isPlaying {
            audioPlayer.pause()
        } else {
            if shouldBePlayedFromBegining {
                audioPlayer.replaceCurrentItem(with: playerItems.last!)
            }
            audioPlayer.play()
        }
        setupImageForPlayButton()
    }
    
    @IBAction func playNextSongButtonPressed(_ sender: Any) {
        
        if currentAudioIndex > tracks.count - 1 {
            return
        }
        
        playNext()
        setupNowPlayingView()
    }
    
    fileprivate func setupNowPlayingView() {
        
        setupImageForPlayButton()
        nowPlayingSongCover.image = tracks[currentAudioIndex].image
        nowPlayingSongName.text = tracks[currentAudioIndex].name
    }
    
    private func prepareForNewSongs() {
        tracks.removeAll()
        playerItems.removeAll()
    }
    
    private func setupImageForPlayButton() {
        
        if tracks.isEmpty {
            return
        }
        
        if isPlaying {
            playButton.setImage(#imageLiteral(resourceName: "pause_nowPlaying"), for: .normal)
        } else {
            playButton.setImage(#imageLiteral(resourceName: "play_now"), for: .normal)
        }
    }
    
    private func playNext() {
        
        if currentAudioIndex + 1 > playerItems.count - 1 {
            currentAudioIndex = 0
        } else {
            currentAudioIndex += 1
        }
        
        let item = AVPlayerItem(asset: playerItems[currentAudioIndex].asset)
        
        audioPlayer.replaceCurrentItem(with: item)
        audioPlayer.play()
    }
    
    fileprivate func clearTracks() {
        currentAudioIndex = 0
        tracks.removeAll()
        playerItems.removeAll()
    }
    
    fileprivate func fillPlayerItems(with songs: [Song]) {
        
        for song in songs {
            guard let url = URL(string: song.audioPath) else {
                print("Incorrect url")
                return
            }
            let asset = AVAsset(url: url)
            let item = AVPlayerItem(asset: asset)
            playerItems.append(item)
        }
    }
    
    private func registerCells(for tableView: UITableView) {
        
        tableView.register(UINib(nibName: "UpperCell", bundle: nil), forCellReuseIdentifier: UpperCell.identifier)
        tableView.register(UINib(nibName: "PreferencesCell", bundle: nil), forCellReuseIdentifier: PreferencesCell.identifier)
        tableView.register(UINib(nibName: "TodaysPlaylistCell", bundle: nil), forCellReuseIdentifier: TodaysPlaylistCell.identifier)
        tableView.register(UINib(nibName: "NewReleasesCell", bundle: nil), forCellReuseIdentifier: NewReleasesCell.identifier)
        tableView.register(UINib(nibName: "NewClipsCell", bundle: nil), forCellReuseIdentifier: NewClipsCell.identifier)
        tableView.register(UINib(nibName: "PopularSongsCell", bundle: nil), forCellReuseIdentifier: PopularSongsCell.identifier)
        tableView.register(UINib(nibName: "SectionHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: SectionHeaderView.identifier)
    }
    
    @objc func startTrialButtonPressed() {
        performSegue(withIdentifier: "musicWasSelected", sender: self)
    }
    
    private func fillDataSource() {
        
        let brightPink = UIColor(red: 244/255.0, green:64/255.0, blue:113/255.0, alpha:1/1.0)
        let lightPurple = UIColor(red: 144/255.0, green:19/255.0, blue:254/255.0, alpha:1/1.0)
        let lightBlue = UIColor(red: 53/255.0, green:181/255.0, blue:214/255.0, alpha:1/1.0)
        let pink = UIColor(red: 226/255.0, green:65/255.0, blue:170/255.0, alpha:1/1.0)
        
        dataSource.append(HeaderData(icon: "section1", title: "Customise your Preferences", dividerColor: lightBlue))
        dataSource.append(HeaderData(icon: "section2", title: "Playlists for today", dividerColor: lightPurple))
        dataSource.append(HeaderData(icon: "section3", title: "New Releases", dividerColor: pink))
        dataSource.append(HeaderData(icon: "section5", title: "Popular Songs", dividerColor: brightPink))
    }
    
    fileprivate func setIndex(for songToFindIndex: Song) {
        
        let index = tracks.index { (song) -> Bool in
            if songToFindIndex == song {
                return true
            }
            return false
        }
        
        guard let songIndex = index else {
            print("Found index is nil")
            return
        }
        currentAudioIndex = Int(songIndex)
    }
}

extension MusicPlayerLandingPage: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return countOfSection
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countOfRowsInSection
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: UpperCell.identifier, for: indexPath) as? UpperCell else {
                return UITableViewCell()
            }
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: PreferencesCell.identifier, for: indexPath) as? PreferencesCell else {
                return UITableViewCell()
            }
            return cell
        case 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TodaysPlaylistCell.identifier, for: indexPath) as? TodaysPlaylistCell else {
                return UITableViewCell()
            }
            cell.albumHandler = self
            self.interactor?.playlistOutput = cell
            interactor?.fetchTodaysPlaylists(amountOfSongs: 10)
            return cell
            
        case 3:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: NewReleasesCell.identifier, for: indexPath) as? NewReleasesCell else {
                return UITableViewCell()
            }
            cell.handler = self
            self.interactor?.albumsOutput = cell
            interactor?.fetchNewAlbums(amount: 10)
            return cell
        case 4:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: PopularSongsCell.identifier, for: indexPath) as? PopularSongsCell else {
                return UITableViewCell()
            }
            cell.hanlder = self
            self.interactor?.songsOutput = cell
            interactor?.fetchSong(10)
            return cell
        default:
            break
        }
        return UITableViewCell()
    }
}

extension MusicPlayerLandingPage: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        switch indexPath.section {
        case 1:
            return 200
        case 3:
            return 300
        case 4:
            return 450
        default:
            return 150
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 1.0
        }
        return headerSize
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 1))
        footerView.backgroundColor = defaultBackgroundColor
        return footerView
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 1))
        headerView.backgroundColor = defaultBackgroundColor
        
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: SectionHeaderView.identifier) as? SectionHeaderView else {
            return UIView()
        }
        
        if section == 0 {
            return headerView
        }
        
        header.sectionIconImageView.image = UIImage(named: dataSource[section - 1].icon)
        header.sectionNameLabel.text = dataSource[section - 1].title
        header.dividerView.backgroundColor = dataSource[section - 1].dividerColor
        
        return header
    }
}

// MARK: - SongsActionHandler
extension MusicPlayerLandingPage: SongsActionHandler {
    
    func musicWasSelected(_ song: Song) {
        
        clearTracks()
        self.tracks.append(song)
        fillPlayerItems(with: tracks)
        setIndex(for: song)
        setupNowPlayingView()
        
        let vc = PlayerViewController.instance()
        self.songActionHandler = vc

        if audioPlayer.rate != 0 {
            audioPlayer.pause()
        }
        
        songActionHandler?.musicWasSelected(song)

        let popupController = PopupController
            .create(self)
            .customize(
                [
                    .animation(.fadeIn),
                    .scrollable(false),
                    .backgroundStyle(.blackFilter(alpha: 0.7))
                ]
            )
            .show(vc)
    
        vc.closeWithSongPaused = { [weak self] (currentItem, time) in
            
            guard let unwrappedSelf = self, let unwrappedCurrentItem = currentItem, let unwrappedTime = time else {
                popupController.dismiss()
                return
            }
            
            let item = AVPlayerItem(asset: unwrappedCurrentItem.asset)
            item.seek(to: unwrappedTime, completionHandler: nil)
            unwrappedSelf.shouldBePlayedFromBegining = true
            unwrappedSelf.playerItems.append(item)
            
            popupController.dismiss()
        }
        
        vc.closeWithSongPlaying = { [weak self] (currentItem, time) in
            
            guard let unwrappedSelf = self, let unwrappedCurrentItem = currentItem, let unwrappedTime = time else {
                popupController.dismiss()
                return
            }
            
            let item = AVPlayerItem(asset: unwrappedCurrentItem.asset)
            item.seek(to: unwrappedTime, completionHandler: nil)
            unwrappedSelf.audioPlayer.replaceCurrentItem(with: item)
            unwrappedSelf.audioPlayer.play()
            unwrappedSelf.shouldBePlayedFromBegining = false
            unwrappedSelf.setupNowPlayingView()
            popupController.dismiss()
        }
        
        vc.closeHandler = { [weak self] in
            guard let unwrappedSelf = self else {
                popupController.dismiss()
                return
            }
            unwrappedSelf.shouldBePlayedFromBegining = true
            popupController.dismiss()
        }
    }
}

// MARK: - AlbumsActionHandler
extension MusicPlayerLandingPage: AlbumsActionHandler {
    
    func albumWasSelected(_ album: Album) {
        
        clearTracks()
        fillPlayerItems(with: album.songs)
        tracks = album.songs
        
        let vc = MusicListViewController.instance()
        self.albumActionHandler = vc
        vc.musicActionHandler = self
        albumActionHandler?.albumWasSelected(album)

        let popup = PopupController
                        .create(self)
                        .customize(
                            [
                                .animation(.slideDown),
                                .scrollable(false),
                                .backgroundStyle(.blackFilter(alpha: 0.7))
                            ])
                        .show(vc)
        
        vc.songWasSelected = { (song) in
           self.nowPlayingSongCover.image = song.image
        self.nowPlayingSongName.text = song.name
        }
        
        vc.closeHandler = {
            popup.dismiss()
        }
        
        vc.closeWithAlbumPaused = { [weak self] (items,index,time) in
            
            guard let unwrappedSelf = self, let unwrappedItems = items, let unwrappedTime = time else {
                popup.dismiss()
                return
            }
            
            unwrappedSelf.playerItems = unwrappedItems
            unwrappedSelf.currentAudioIndex = index
            let item = AVPlayerItem(asset: unwrappedSelf.playerItems[index].asset)
            item.seek(to: unwrappedTime, completionHandler: nil)
            unwrappedSelf.shouldBePlayedFromBegining = false
            unwrappedSelf.audioPlayer.replaceCurrentItem(with: item)
            unwrappedSelf.albumActionHandler?.albumWasSelected(album)
            unwrappedSelf.setupImageForPlayButton()
        }
        
        vc.closeWithAlbumPlaying = { [weak self] (items,index,time) in
            
            guard let unwrappedSelf = self, let unwrappedItems = items, let unwrappedTime = time else {
                popup.dismiss()
                return
            }
            
            unwrappedSelf.playerItems = unwrappedItems
            unwrappedSelf.currentAudioIndex = index
            let item = AVPlayerItem(asset: unwrappedSelf.playerItems[index].asset)
            item.seek(to: unwrappedTime, completionHandler: nil)
            unwrappedSelf.audioPlayer.replaceCurrentItem(with: item)
            unwrappedSelf.audioPlayer.play()
            unwrappedSelf.albumActionHandler?.albumWasSelected(album)
            unwrappedSelf.shouldBePlayedFromBegining = false
            unwrappedSelf.setupNowPlayingView()
        }
    }
}

// MARK: - MusicPlayerActionHandler
extension MusicPlayerLandingPage: MusicPlayerActionHandler {
    
    func songWasSelectedFromAlbum() {
        if audioPlayer.rate != 0 {
            audioPlayer.pause()
        }
    }
}



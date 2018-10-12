//
//  MusicPlayerLandingPage.swift
//  Music Player
//
//  Created by Даниил Смирнов on 09.09.2018.
//  Copyright © 2018 polat. All rights reserved.
//

import UIKit
import AVFoundation
import KDEAudioPlayer

class MusicPlayerLandingPage: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nowPlayingSongCover: UIImageView!
    @IBOutlet weak var nowPlayingSongName: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    fileprivate var audioPlayer = AudioPlayer()
    fileprivate var playerItems = [AudioItem]()

    fileprivate var tracks = [Song]()
    fileprivate var shouldBePlayedFromBegining = false
    fileprivate var currentAudioIndex = 0
    fileprivate var userTappedOnController = false
    
    fileprivate var isPlaying: Bool {
        get {
            return audioPlayer.rate != 0
        }
    }
    
    fileprivate var interactor: MusicPlayerLandingPageInteractor?
    fileprivate weak var outputSingleValue: LandingPageViewOutputSingleValue?
    fileprivate weak var outputMultipleValue: LandingPageViewOutputMultipleValues?
    fileprivate weak var songActionHandler: SongActionHandler?
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
        nowPlayingSongName.text = "Not playing".localized
        let audioSession = AVAudioSession()
        do {
            try audioSession.setActive(true)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    @IBAction func nowPlayingViewTapped(_ sender: Any) {
        
        if tracks.isEmpty {
            return
        }
        userTappedOnController = true
        self.musicWasSelected(tracks[currentAudioIndex])
    }
    
    @IBAction func playNowPlayingSongButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func playNextSongButtonPressed(_ sender: Any) {
    
    }
    
    fileprivate func setupNowPlayingView() {
        
        nowPlayingSongCover.image = tracks[currentAudioIndex].image
        nowPlayingSongName.text = tracks[currentAudioIndex].name
    }
    
    fileprivate func createItem(with audioPath: String) -> AudioItem? {
        return AudioItem(mediumQualitySoundURL: URL(string: audioPath))
    }
    
    fileprivate func createItems(with audioPaths: [String]) -> [AudioItem]? {
        let urls = audioPaths.map { URL(string: $0) }
        let result = urls.map { AudioItem(mediumQualitySoundURL: $0) } as! [AudioItem]
        return result
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
    
    private func fillDataSource() {
        
        let brightPink = UIColor(red: 244/255.0, green:64/255.0, blue:113/255.0, alpha:1/1.0)
        let lightPurple = UIColor(red: 144/255.0, green:19/255.0, blue:254/255.0, alpha:1/1.0)
        let lightBlue = UIColor(red: 53/255.0, green:181/255.0, blue:214/255.0, alpha:1/1.0)
        let pink = UIColor(red: 226/255.0, green:65/255.0, blue:170/255.0, alpha:1/1.0)
        
        dataSource.append(HeaderData(icon: "section1", title: "Customise your Preferences".localized, dividerColor: lightBlue))
        dataSource.append(HeaderData(icon: "section2", title: "Playlists for today".localized, dividerColor: lightPurple))
        dataSource.append(HeaderData(icon: "section3", title: "New Releases".localized, dividerColor: pink))
        dataSource.append(HeaderData(icon: "section5", title: "Popular Songs".localized, dividerColor: brightPink))
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
extension MusicPlayerLandingPage: SongActionHandler {

    func musicWasSelected(_ song: Song) {
        
        guard let item = createItem(with: song.audioPath) else {
            print("item is nil")
            return
        }
        playerItems.append(item)
        
        let playerVc = PlayerViewController.instance()
        self.songActionHandler = playerVc
        playerVc.playerDelegate = self
        audioPlayer.delegate = playerVc
        self.songActionHandler?.musicWasSelected(song)
        
        let popup = PopupController
            .create(self)
            .customize(
                [
                    .animation(.slideDown),
                    .scrollable(false),
                    .backgroundStyle(.blackFilter(alpha: 0.7))
                ])
            .show(playerVc)
        
        playerVc.closeHandler = {
            popup.dismiss()
        }
    }
}

// MARK: - AlbumsActionHandler
extension MusicPlayerLandingPage: AlbumsActionHandler {
    
    func albumWasSelected(_ album: Album) {
        
        guard let items = createItems(with: album.songs.map { $0.audioPath }) else { return }
        playerItems = items
        let vc = MusicListViewController.instance(from: self)
        self.albumActionHandler = vc
        vc.musicActionHandler = self
        albumActionHandler?.albumWasSelected(album)
        vc.playerDelegate = self

        let popup = PopupController
                        .create(self)
                        .customize(
                            [
                                .animation(.slideDown),
                                .scrollable(false),
                                .backgroundStyle(.blackFilter(alpha: 0.7))
                            ])
                        .show(vc)
        vc.songWasSelected = { [weak self] (song) in
            guard let unwrappedSelf = self else { return }
            unwrappedSelf.nowPlayingSongCover.image = song.image
            unwrappedSelf.nowPlayingSongName.text = song.name
        }
        
        vc.closeHandler = {
            popup.dismiss()
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

// MARK: - PlayerViewControllerDelegate
extension MusicPlayerLandingPage: PlayerViewControllerDelegate {
    
    func didChangeTime(to newTime: TimeInterval) {
        audioPlayer.seek(to: newTime)
    }
    
    func didPressPlayButton() {
        (audioPlayer.state == .playing) ? audioPlayer.pause() : audioPlayer.play(items: playerItems)
    }
    
    func didPressNextButton() {
        if !audioPlayer.hasNext {
            audioPlayer.pause()
        }
        audioPlayer.removeItem(at: audioPlayer.currentItemIndexInQueue!)
    }
    
    func didPressPreviousButton() {
        if !audioPlayer.hasPrevious {
            audioPlayer.pause()
        }
    }
}

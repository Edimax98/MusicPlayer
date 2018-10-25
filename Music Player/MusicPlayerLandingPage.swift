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

enum AccessStatus {
    case available
    case denied
}

class MusicPlayerLandingPage: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nowPlayingSongCover: UIImageView!
    @IBOutlet weak var nowPlayingSongName: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    fileprivate let headerSize: CGFloat = 60
    fileprivate let defaultBackgroundColor = UIColor(red: 13 / 255, green: 15 / 255, blue: 22 / 255, alpha: 1)
    
    fileprivate var audioPlayer = AudioPlayer()
    var accessStatus = AccessStatus.denied
    var wasSubscriptionSkipped = false
    fileprivate var option: Subscription?
    fileprivate var tracks = [Song]()
    fileprivate var dataSource = [HeaderData]()
    fileprivate var currentAudioIndex = 0
    fileprivate var songSelectedFromAlbum = false
    fileprivate var userTappedOnController = false
    fileprivate let countOfRowsInSection = 1
    fileprivate let countOfSection = 5

    fileprivate let playerVc = PlayerViewController.instance()
    
    fileprivate var interactor: MusicPlayerLandingPageInteractor?
    fileprivate weak var outputSingleValue: LandingPageViewOutputSingleValue?
    fileprivate weak var outputMultipleValue: LandingPageViewOutputMultipleValues?
    fileprivate weak var songActionHandler: SongActionHandler?
    fileprivate weak var albumActionHandler: AlbumsActionHandler?

	override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = defaultBackgroundColor
        activityIndicator.isHidden = true
        playButton.setImage(UIImage(named: "pause_nowPlaying"), for: .selected)
        nowPlayingSongCover.layer.cornerRadius = 2
        let networkService = NetworkService()
        interactor = MusicPlayerLandingPageInteractor(networkService)
        registerCells(for: tableView)
        fillDataSource()
        nowPlayingSongName.text = "Not playing".localized
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let _ = SubscriptionService.shared.currentSubscription {
            accessStatus = .available
        } else if !wasSubscriptionSkipped {
            performSegue(withIdentifier: "toSub", sender: self)
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
    
    @IBAction func nowPlayingViewTapped(_ sender: Any) {
        
        guard accessStatus == .available else {
            performSegue(withIdentifier: "toSub", sender: self)
            return
        }
        
        if tracks.isEmpty {
            return
        }
        
        userTappedOnController = true
        guard let index = audioPlayer.currentItemIndexInQueue else { return }
        
        if audioPlayer.state == .paused {
            audioPlayer.resume()
            self.sendSong(tracks[index])
            return
        }
        self.sendSong(tracks[index])
    }
    
    @IBAction func playNowPlayingSongButtonPressed(_ sender: Any) {
        playButton.isSelected = !playButton.isSelected
        
        switch audioPlayer.state {
        case .buffering:
            audioPlayer.pause()
        case .playing:
            audioPlayer.pause()
        case .paused:
            audioPlayer.resume()
        case .stopped:
            guard let items = audioPlayer.items else { return }
            audioPlayer.play(items: items, startAtIndex: currentAudioIndex)
        case .waitingForConnection:
            audioPlayer.pause()
        case .failed(let error):
            print("failed", error)
        }
    }
    
    @IBAction func playNextSongButtonPressed(_ sender: Any) {
		audioPlayer.nextOrStop()
        setupNowPlayingView()
    }
    
    fileprivate func setupNowPlayingView() {
        
        if audioPlayer.state == .paused || audioPlayer.state == .stopped {
            playButton.isSelected = false
        } else {
            playButton.isSelected = true
        }
        
        guard let index = audioPlayer.currentItemIndexInQueue else { return }
        nowPlayingSongCover.image = tracks[index].image
        nowPlayingSongName.text = tracks[index].name
    }
    
    fileprivate func createItem(with audioPath: String) -> AudioItem? {
        return AudioItem(mediumQualitySoundURL: URL(string: audioPath))
    }
    
    fileprivate func createItems(with audioPaths: [String]) -> [AudioItem]? {
        let urls = audioPaths.map { URL(string: $0) }
        let result = urls.map { AudioItem(mediumQualitySoundURL: $0) } as! [AudioItem]
        return result
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
            self.interactor?.songsOutput = cell
            //cell.mediator.add(recipient: playerVc)
            cell.songWasTapped = self
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
	
	func setCurrentIndex(from song: Song) {
        guard let index = tracks.firstIndex(of: song) else {
            print("cant find index")
            return
        }
		currentAudioIndex = index
	}
}

// MARK: - SongsActionHandler
extension MusicPlayerLandingPage: SongActionHandler {

    func musicWasSelected(_ song: Song) {
        
        guard accessStatus == .available else {
            performSegue(withIdentifier: "toSub", sender: self)
            return
        }
        
		setCurrentIndex(from: song)
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
            self.setupNowPlayingView()
            popup.dismiss()
        }
    }
}

// MARK: - AlbumsActionHandler
extension MusicPlayerLandingPage: AlbumsActionHandler {
    
    func albumWasSelected(_ album: Album) {
        
        guard accessStatus == .available else {
            performSegue(withIdentifier: "toSub", sender: self)
            return
        }
        
        tracks = album.songs
        let musicListVc = MusicListViewController.instance(from: self)
        self.albumActionHandler = musicListVc
        audioPlayer.delegate = musicListVc
        musicListVc.songActionHandler = self
        musicListVc.musicActionHandler = self
		musicListVc.playerDelegate = self
		albumActionHandler?.albumWasSelected(album)

        let popup = PopupController
                        .create(self)
                        .customize(
                            [
                                .animation(.slideDown),
                                .scrollable(false),
                                .backgroundStyle(.blackFilter(alpha: 0.7))
                            ])
                        .show(musicListVc)
		
        musicListVc.songWasSelected = { [weak self] (song) in
            guard let unwrappedSelf = self else { return }
            unwrappedSelf.nowPlayingSongCover.image = song.image
            unwrappedSelf.nowPlayingSongName.text = song.name
        }

        musicListVc.closeHandler = {
            popup.dismiss()
        }
    }
}

// MARK: - MusicPlayerActionHandler
extension MusicPlayerLandingPage: MusicPlayerActionHandler {
    
    func songWasSelectedFromAlbum(_ song: Song) {
        
        if audioPlayer.items != nil {
            audioPlayer.stop()
        }
        setCurrentIndex(from: song)
        guard let items = createItems(with: tracks.map { $0.audioPath }) else { return }
        audioPlayer.play(items: items, startAtIndex: currentAudioIndex)
    }
}

extension MusicPlayerLandingPage: LandingPageViewOutputSingleValue {
    
    func sendSong(_ song: Song) {

        guard let item = createItem(with: song.audioPath) else {
            print("item is nil")
            return
        }
        
        if audioPlayer.items != nil && userTappedOnController == false {
           audioPlayer.stop()
        }
        
        userTappedOnController = false
        audioPlayer.play(item: item)
        tracks.append(song)
        setCurrentIndex(from: song)
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
            self.setupNowPlayingView()
            popup.dismiss()
        }
    }
}

// MARK: - PlayerViewControllerDelegate
extension MusicPlayerLandingPage: PlayerViewControllerDelegate {
    
    func didChangeVolume(to newVolume: Float) {
        audioPlayer.volume = newVolume
    }
	
    func didChangeTime(to newTime: TimeInterval) {
        audioPlayer.seek(to: newTime)
    }
    
    func didPressPlayButton() {
        
        switch audioPlayer.state {
        case .buffering:
            audioPlayer.pause()
        case .playing:
            audioPlayer.pause()
        case .paused:
            audioPlayer.resume()
        case .stopped:
            guard let items = audioPlayer.items else { return }
            audioPlayer.play(items: items, startAtIndex: currentAudioIndex)
        case .waitingForConnection:
            audioPlayer.pause()
        case .failed(let error):
            print("failed", error)
        }
    }
    
	func didPressNextButton(completion: @escaping (_ newSong: Song) -> Void) {
        
        if audioPlayer.items?.count == 1 {
            audioPlayer.pause()
            audioPlayer.seek(to: 0)
            return
        }
        
		audioPlayer.next()
        
        if let index = audioPlayer.currentItemIndexInQueue {
            completion(tracks[index])
        } else {
            completion(tracks[0])
        }
    }
	
	func didPressPreviousButton(completion: @escaping (Song) -> Void) {

        if audioPlayer.items?.count == 1 {
            audioPlayer.pause()
            audioPlayer.seek(to: 0)
            return
        }
        
        audioPlayer.previous()
        
        if let index = audioPlayer.currentItemIndexInQueue {
            completion(tracks[index])
        } else {
            completion(tracks[0])
        }
	}
}

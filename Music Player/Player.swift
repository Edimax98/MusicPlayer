//
//  Player.swift
//  Music Player
//
//  Created by Даниил on 08/10/2018.
//  Copyright © 2018 polat. All rights reserved.
//

import AVFoundation

enum PlayerPlaybackState: CustomStringConvertible {
    
    case playing
    case paused
    case stopped
    
    var description: String {
        switch self {
        case .playing:
            return "Player is playing".localized
        case .paused:
            return "Player is paused".localized
        case .stopped:
            return "Player stopped".localized
        }
    }
}

enum PlayerState: CustomStringConvertible {
    case urlNotSet
    case readyToPlay
    case loading
    case loadingFinished
    case error
    
    var description: String {
        switch self {
        case .urlNotSet:
            return "URL was not set".localized
        case .readyToPlay:
            return "Player ready to play".localized
        case .loading:
            return "Loading in process".localized
        case .loadingFinished:
            return "Loading is completed".localized
        case .error:
            return "Error occured".localized
        }
    }
}

protocol PlayerDelegate: class {
    
    func player(_ player: Player, playerStateDidChanged state: PlayerState)
    
    func player(_ player: Player, playerPlaybackStateDidChange state: PlayerPlaybackState)
    
    func player(_ player: Player, itemUrlDidChange url: URL?)
}

class Player: NSObject {
    
    static let shared = Player()

    weak var delegate: PlayerDelegate?
    
    var itemURL: URL? {
        didSet {
            itemURLDidChange(with: itemURL)
        }
    }
    
    var isPlaying: Bool {
        switch playbackState {
        case .playing:
            return true
        case .stopped, .paused:
            return false
        }
    }
    
    private(set) var state = PlayerState.urlNotSet {
        didSet {
            guard oldValue != state else { return }
            delegate?.player(self, playerStateDidChanged: state)
        }
    }
    
    private(set) var playbackState = PlayerPlaybackState.stopped {
        didSet {
            guard oldValue != playbackState else { return }
            delegate?.player(self, playerPlaybackStateDidChange: playbackState)
        }
    }

    private var player: AVPlayer?
    private var lastPlayerItem: AVPlayerItem?
    private var headphonesConnected = false
    private let reachability = Reachability()
    private var isConnected = false
    private var playerItem: AVPlayerItem? {
        didSet {
            playerItemDidChange()
        }
    }
    
    private override init() {
        super.init()
        
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(AVAudioSessionCategoryPlayback, with: [.defaultToSpeaker, .allowBluetooth])
        
        setupNotifications()
        checkHeadphonesConnection(outputs: AVAudioSession.sharedInstance().currentRoute.outputs)
        
        do {
            try reachability?.startNotifier()
            NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(notification:)), name: .reachabilityChanged, object: reachability)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func play() {
        
        guard let player = self.player else { print("Player is nil"); return }
        if player.currentItem == nil, playerItem != nil {
            player.replaceCurrentItem(with: playerItem)
        }
        player.play()
        playbackState = .playing
    }
    
    func pause() {
        guard let player = self.player else { return }
        player.pause()
        playbackState = .paused
    }
    
    func stop() {
        guard let player = self.player else { return }
        player.replaceCurrentItem(with: nil)
        playbackState = .stopped
    }
    
    func togglePlaying() {
        isPlaying ? pause() : play()
    }
    
    private func setupPlayer(with asset: AVAsset) {
        
        if player == nil {
            player = AVPlayer()
        }
        playerItem = AVPlayerItem(asset: asset)
    }
    
    private func resetPlayer() {
        stop()
        player = nil
        playerItem = nil
        lastPlayerItem = nil
    }
    
    private func reloadItems() {
        player?.replaceCurrentItem(with: nil)
        player?.replaceCurrentItem(with: playerItem)
    }
    
    private func preparePlayer(with asset: AVAsset?, completionHandler: @escaping (_ isPlayable: Bool, _ asset: AVAsset?) -> Void) {
        
        guard let unwrappedAsset = asset else { completionHandler(false,nil); return }
        
        let requestedKey = ["playable"]
        
        asset?.loadValuesAsynchronously(forKeys: requestedKey) {
            
            DispatchQueue.main.async {
                var error: NSError?
                let keyStatus = asset?.statusOfValue(forKey: "playable", error: &error)
                if keyStatus == AVKeyValueStatus.failed || !unwrappedAsset.isPlayable {
                    completionHandler(false,nil)
                    return
                }
                completionHandler(true, asset)
            }
        }
    }
    
    private func itemURLDidChange(with url: URL?) {
        resetPlayer()
        guard let unwrappedUrl = url else { state = .urlNotSet; return }
        
        state = .loading
        
        preparePlayer(with: AVAsset(url: unwrappedUrl)) { (success,asset) in
            guard success, let unwrappedAsset = asset else {
                self.resetPlayer()
                self.state = .error
                return
            }
            self.setupPlayer(with: unwrappedAsset)
        }
    }
    
    private func playerItemDidChange() {
        
        guard lastPlayerItem != playerItem else { return }
        
        if let item = lastPlayerItem {
            pause()
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
            item.removeObserver(self, forKeyPath: "status")
            item.removeObserver(self, forKeyPath: "playbackBufferEmpty")
            item.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
            item.removeObserver(self, forKeyPath: "timedMetadata")
        }
        
        lastPlayerItem = playerItem
        
        if let item = playerItem {
            item.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
            item.addObserver(self, forKeyPath: "playbackBufferEmpty", options: NSKeyValueObservingOptions.new, context: nil)
            item.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: NSKeyValueObservingOptions.new, context: nil)
            item.addObserver(self, forKeyPath: "timedMetadata", options: NSKeyValueObservingOptions.new, context: nil)
            
            player?.replaceCurrentItem(with: item)
        }
        delegate?.player(self, itemUrlDidChange: itemURL)
    }

    deinit {
        resetPlayer()
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(handleInterruption), name: .AVAudioSessionInterruption, object: nil)
        notificationCenter.addObserver(self, selector: #selector(handleRouteChange), name: .AVAudioSessionRouteChange, object: nil)
    }
    
    @objc private func handleInterruption(notification: Notification) {
        
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSessionInterruptionType(rawValue: typeValue) else {
                return
        }
        
        switch type {
        case .began:
            pause()
        case .ended:
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { break }
            let options = AVAudioSessionInterruptionOptions(rawValue: optionsValue)
            options.contains(.shouldResume) ? play() : pause()
        }
    }
    
    private func checkNetworkInterruption() {
        guard
            let item = playerItem,
            !item.isPlaybackLikelyToKeepUp,
            reachability?.connection != .none else { return }
        
        player?.pause()
        
        // Wait 1 sec to recheck and make sure the reload is needed
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            if !item.isPlaybackLikelyToKeepUp { self.reloadItems() }
            self.isPlaying ? self.player?.play() : self.player?.pause()
        }
    }
    
    private func checkHeadphonesConnection(outputs: [AVAudioSessionPortDescription]) {
        for output in outputs where output.portType == AVAudioSessionPortHeadphones {
            headphonesConnected = true
            break
        }
        headphonesConnected = false
    }
    
    @objc private func handleRouteChange(notification: Notification) {
        
        guard let userInfo = notification.userInfo,
            let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
            let reason = AVAudioSessionRouteChangeReason(rawValue:reasonValue) else { return }
        
        switch reason {
        case .newDeviceAvailable:
            checkHeadphonesConnection(outputs: AVAudioSession.sharedInstance().currentRoute.outputs)
        case .oldDeviceUnavailable:
            guard let previousRoute = userInfo[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription else { return }
            checkHeadphonesConnection(outputs: previousRoute.outputs);
            DispatchQueue.main.async { self.headphonesConnected ? () : self.pause() }
        default: break
        }
    }
    
    @objc func reachabilityChanged(notification: Notification) {
        
        guard let reachability = notification.object as? Reachability else { return }
        
        // Check if the internet connection was lost
        if reachability.connection != .none, !isConnected {
            checkNetworkInterruption()
        }
        isConnected = reachability.connection != .none
    }
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if let item = object as? AVPlayerItem, let keyPath = keyPath, item == self.playerItem {
            
            switch keyPath {
                
            case "status":
                
                if player?.status == AVPlayerStatus.readyToPlay {
                    self.state = .readyToPlay
                } else if player?.status == AVPlayerStatus.failed {
                    self.state = .error
                }
                
            case "playbackBufferEmpty":
                
                if item.isPlaybackBufferEmpty {
                    self.state = .loading
                    self.checkNetworkInterruption()
                }
                
            case "playbackLikelyToKeepUp":
                
                self.state = item.isPlaybackLikelyToKeepUp ? .loadingFinished : .loading
                
          //  case "timedMetadata":
               // let rawValue = item.timedMetadata?.first?.value as? String
               // timedMetadataDidChange(rawValue: rawValue)
                
            default:
                break
            }
        }
    }
    
}

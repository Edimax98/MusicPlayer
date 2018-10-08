//
//  DeepLinkNavigator.swift
//  Music Player
//
//  Created by Даниил on 08/10/2018.
//  Copyright © 2018 polat. All rights reserved.
//

import UIKit

class DeepLinkNavigator {
    
    private init() { }
    static let shared = DeepLinkNavigator()
    private var popupController = PopupController()
    private let popupOptions = [
        PopupCustomOption.layout(.top),
        PopupCustomOption.animation(.fadeIn),
        PopupCustomOption.scrollable(false),
        PopupCustomOption.backgroundStyle(.blackFilter(alpha: 0.7))]
    
    func proceed(with deepLinkOption: DeepLinkOption?) {
        
        guard let option = deepLinkOption else { return }
        
        switch option {
        case .player:
            let playerVc = PlayerViewController.controllerInStoryboard(UIStoryboard(name: "PlayerView", bundle: nil))
            popupController.customize(popupOptions).show(playerVc)
        case .mainView:
            let mainView = PlayerViewController.controllerInStoryboard(UIStoryboard(name: "Main", bundle: nil))
            popupController.customize(popupOptions).show(mainView)
        case .musicList:
            let musicList = PlayerViewController.controllerInStoryboard(UIStoryboard(name: "MusicList", bundle: nil))
            popupController.customize(popupOptions).show(musicList)
        }
    }
}

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
    var alertController = UIAlertController()
    
    func proceed(with deeplinkType: DeeplinkType) {
        
        switch deeplinkType {
        case .themePlaylist(themeName: let theme):
            openView(with: theme)
        default:
            break
        }
    }
    
    private func openView(with theme: String) {
        if let vc = UIApplication.shared.keyWindow?.rootViewController as? MusicPlayerLandingPage {
            let themePlaylistsView = ThemePlaylistsViewController.controllerInStoryboard(UIStoryboard(name: "Main", bundle: nil), identifier: "ThemePlaylistsVc")
            //themePlaylistsView.interactor?.fetchSongs(amount: 100, tags: ["Happy"])
        }
    }
}

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
    var wasProceeded = false
    
    var dataLoaded: (() -> Void)?

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
            vc.interactor?.fetchSongs(amount: 10, tags: [theme]) { (albums ,theme) in
                let mediator = Mediator()
                self.wasProceeded = true
                mediator.add(recipient: vc)
                mediator.add(recipient: vc.musicListVc)
                mediator.send(album: albums.first!)
                self.dataLoaded?()
            }
        }
    }
}

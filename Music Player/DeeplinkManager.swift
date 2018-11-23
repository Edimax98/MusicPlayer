//
//  DeepLinkOption.swift
//  Music Player
//
//  Created by Даниил on 05/10/2018.
//  Copyright © 2018 polat. All rights reserved.
//

import Foundation

enum DeeplinkType {
    case player
    case mainView
    case musicList
    case themePlaylist(themeName: String)
}

let DeepLinker = DeepLinkManager()

class DeepLinkManager {
    
    private var deeplinkType: DeeplinkType?
    
    fileprivate init() { }
    
    func handleDeeplink(url: URL) -> Bool {
        deeplinkType = DeeplinkParser.shared.parseDeepLink(url)
        return deeplinkType != nil
    }
    
    func checkDeeplink() {
        guard let deeplinkType = deeplinkType else { return }
        DeepLinkNavigator.shared.proceed(with: deeplinkType)
        self.deeplinkType = nil
    }
}

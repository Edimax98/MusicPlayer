//
//  DeepLinkOption.swift
//  Music Player
//
//  Created by Даниил on 05/10/2018.
//  Copyright © 2018 polat. All rights reserved.
//

import Foundation

struct DeepLinkURLConstants {
    static let player = "player"
    static let mainView = "main"
    static let musicList = "list"
}

enum DeepLinkOption {
    
    case player
    case mainView
    case musicList
    
    static func build(with userActivity: NSUserActivity) -> DeepLinkOption? {
        
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let url = userActivity.webpageURL,
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
            let host = url.host {
            
            var pathComponents = components.path.components(separatedBy: "/")
            pathComponents.removeFirst()
            
            switch host {
            case DeepLinkURLConstants.player:
                return .player
            case DeepLinkURLConstants.mainView:
                return .mainView
            case DeepLinkURLConstants.musicList:
                return .musicList
            default:
                break
            }
        }
        return nil
    }
}

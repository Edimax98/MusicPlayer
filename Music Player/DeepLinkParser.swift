//
//  DeepLinkParser.swift
//  Music Player
//
//  Created by Даниил on 23/11/2018.
//  Copyright © 2018 polat. All rights reserved.
//

import Foundation

class DeeplinkParser {
    
    static let shared = DeeplinkParser()
    private init() { }
    
    func parseDeepLink(_ url: URL) -> DeeplinkType? {
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true), let host = components.host else {
            return nil
        }
        
        var pathComponents = components.path.components(separatedBy: "/")
        pathComponents.removeFirst()
        
        switch host {w
        case "main":
            return DeeplinkType.mainView
        case "themePlaylists":
            if let theme = pathComponents.first {
                return DeeplinkType.themePlaylist(themeName: theme)
            }
        default:
            break
        }
        return nil
    }
}

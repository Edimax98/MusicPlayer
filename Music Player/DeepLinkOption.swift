//
//  DeepLinkOption.swift
//  Music Player
//
//  Created by Даниил on 05/10/2018.
//  Copyright © 2018 polat. All rights reserved.
//

import Foundation

struct DeepLinkURLConstants {
    // the end of url paths to present views. deeplink://views/login
}

enum DeepLinkOption {
    
    static func build(with userActivity: NSUserActivity) -> DeepLinkOption? {
        
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let url = userActivity.webpageURL,
            let _ = URLComponents(url: url, resolvingAgainstBaseURL: true) {
            
            //TODO: extract string and match with DeepLinkURLConstants
        }
        return nil
    }
}


//
//  LaunchControl.swift
//  Music Player
//
//  Created by Даниил on 24/10/2018.
//  Copyright © 2018 polat. All rights reserved.
//

import Foundation

enum LaunchOption {
    case userIsNotSubcribed
    case userSubscribed
}

class LaunchControl {
    
    let option: LaunchOption
    
    init(option: LaunchOption = .userIsNotSubcribed) {
        self.option = option
    }
}

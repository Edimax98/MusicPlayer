//
//  FacebookEventsEnviroment.swift
//  Music Player
//
//  Created by Даниил on 30/11/2018.
//  Copyright © 2018 polat. All rights reserved.
//

import Foundation

enum Enviroment: String {
    case test = "Test"
    case production = "Production"
}

class FacebookEventsEviroment {
    
    static let shared = FacebookEventsEviroment()
    
    var enviroment: Enviroment {
        get {
            return .production
        }
    }
    private init() {}
}

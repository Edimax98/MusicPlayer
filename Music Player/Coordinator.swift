//
//  Coordinator.swift
//  Music Player
//
//  Created by Даниил on 05/10/2018.
//  Copyright © 2018 polat. All rights reserved.
//

import Foundation

protocol Coordinator: class {
    
    func start()
    func start(with option: DeepLinkOption?)
}

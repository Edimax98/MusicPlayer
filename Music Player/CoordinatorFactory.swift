//
//  CoordinatorFactory.swift
//  Music Player
//
//  Created by Даниил on 05/10/2018.
//  Copyright © 2018 polat. All rights reserved.
//

import Foundation

protocol CoordinatorFactory {
    
    func makeMainPageCoordinator() -> (configurator: Coordinator, toPresent: Presentable?)
    
    func makePlayerCoordinator(_ popupController: PopupController) -> Coordinator
    
    func makeSongListCoordinator(_ popupController: PopupController) -> Coordinator
}

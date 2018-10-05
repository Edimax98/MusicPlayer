//
//  MainPageFlow.swift
//  Music Player
//
//  Created by Даниил on 05/10/2018.
//  Copyright © 2018 polat. All rights reserved.
//

import Foundation

class MainPageCoordinator: BaseCoordinator {
    
    private let mainPageView: MainPageView
    private let coordinatorFactory: CoordinatorFactory
    
    init(mainPageView: MainPageView, coordinatorFactory: CoordinatorFactory) {
        self.mainPageView = mainPageView
        self.coordinatorFactory = coordinatorFactory
    }
    
    override func start() {
        mainPageView.onSongFlowSelect = runPlayerFlow()
        mainPageView.onAlbumFlowSelect = runSongListFlow()
    }
    
    private func runPlayerFlow() -> ((PopupController) -> Void)? {
        return { popupController in
            let playerCoordinator = self.coordinatorFactory.makePlayerCoordinator(popupController)
            playerCoordinator.start()
            self.addDependency(playerCoordinator)
        }
    }
    
    private func runSongListFlow() -> ((PopupController) -> Void)? {
        return { popupController in
            let songListCoordinator = self.coordinatorFactory.makeSongListCoordinator(popupController)
            songListCoordinator.start()
            self.addDependency(songListCoordinator)
        }
    }
}

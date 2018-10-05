//
//  PlayerCoordinator.swift
//  Music Player
//
//  Created by Даниил on 05/10/2018.
//  Copyright © 2018 polat. All rights reserved.
//

import Foundation

class PlayerCoordinator: BaseCoordinator {
    
    private let factory: PlayerModuleFactory
    private let coordinatorFactory: CoordinatorFactory
    private let router: Router
    
    init(router: Router, coordinatorFactory: CoordinatorFactory, factory: PlayerModuleFactory) {
        self.router = router
        self.coordinatorFactory = coordinatorFactory
        self.factory = factory
    }
    
    override func start() {
        showPlayer()
    }
    
    private func showPlayer() {
        
        let playerOutput = factory.makePlayerOutput()
        playerOutput.onExit = { [weak self] in
            self?.showPlayer()
        }
        router.setRootModule(playerOutput)
    }
    
    private func showMainPage() {
        let mainPage = factory.makeMainPageOutput()
        router.push(mainPage)
    }
}

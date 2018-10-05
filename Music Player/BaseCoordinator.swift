//
//  BaseCoordinator.swift
//  Music Player
//
//  Created by Даниил on 05/10/2018.
//  Copyright © 2018 polat. All rights reserved.
//

import Foundation

class BaseCoordinator: Coordinator {
    
    var childControllers = [Coordinator]()
    
    func start() {
        start(with: nil)
    }
    
    func start(with option: DeepLinkOption?) { }
    
    func addDependency(_ coordinator: Coordinator) {
        for element in childControllers {
            if element === coordinator { return }
        }
        childControllers.append(coordinator)
    }
    
    func removeDependency(_ coordinator: Coordinator?) {
        
        guard !childControllers.isEmpty, let coordinator = coordinator else { return }
        
        for (index,element) in childControllers.enumerated() {
            if element === coordinator {
                childControllers.remove(at: index)
                break
            }
        }
    }
}

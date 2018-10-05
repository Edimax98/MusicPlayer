//
//  Presentable.swift
//  Music Player
//
//  Created by Даниил on 05/10/2018.
//  Copyright © 2018 polat. All rights reserved.
//

import UIKit

protocol Presentable {
    
    func toPresent() -> UIViewController?
}

extension UIViewController: Presentable {
    
    func toPresent() -> UIViewController? {
        return self
    }
}

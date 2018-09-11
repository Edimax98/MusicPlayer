//
//  TagCellLayoutDelegate.swift
//  Music Player
//
//  Created by Даниил on 11.09.2018.
//  Copyright © 2018 polat. All rights reserved.
//

import UIKit

public protocol TagCellLayoutDelegate: NSObjectProtocol {
    
    func tagCellLayoutTagSize(layout: TagCellLayout, atIndex index:Int) -> CGSize
}

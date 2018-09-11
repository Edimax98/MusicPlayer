//
//  LayoutAlignment.swift
//  Music Player
//
//  Created by Даниил on 11.09.2018.
//  Copyright © 2018 polat. All rights reserved.
//

import UIKit

public extension TagCellLayout {
    
    public enum LayoutAlignment: Int {
        
        case left
        case center
        case right
    }
}

extension TagCellLayout.LayoutAlignment {
    
    var distributionDivisionFactor: CGFloat {
        switch self {
        case .center:
            return 2
        default:
            return 1
        }
    }
}

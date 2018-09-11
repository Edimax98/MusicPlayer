//
//  LayoutInfo.swift
//  Music Player
//
//  Created by Даниил on 11.09.2018.
//  Copyright © 2018 polat. All rights reserved.
//

import UIKit

public extension TagCellLayout {
    
    struct LayoutInfo {
        
        var layoutAttribute: UICollectionViewLayoutAttributes
        var whiteSpace: CGFloat = 0.0
        var isFirstElementInARow = false
        
        init(layoutAttribute: UICollectionViewLayoutAttributes) {
            self.layoutAttribute = layoutAttribute
        }
    }
}

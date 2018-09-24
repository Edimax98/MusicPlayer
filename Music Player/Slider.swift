//
//  Slider.swift
//  Music Player
//
//  Created by Даниил on 24.09.2018.
//  Copyright © 2018 polat. All rights reserved.
//

import UIKit

class Slider: UISlider {

    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        return CGRect(x: 0, y: 0, width: 313, height: 31)
    }
}

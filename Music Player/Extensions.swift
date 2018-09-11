//
//  Extensions.swift
//  Music Player
//
//  Created by Даниил on 11.09.2018.
//  Copyright © 2018 polat. All rights reserved.
//

import UIKit

extension UIView {
    class func fromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
}

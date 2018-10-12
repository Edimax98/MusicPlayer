//
//  NSObjectExtension.swift
//  Music Player
//
//  Created by Даниил on 05/10/2018.
//  Copyright © 2018 polat. All rights reserved.
//

import Foundation
import AVFoundation

extension NSObject {
    class var nameOfClass: String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
}

extension CMTime {
    /// Initializes a `CMTime` instance from a time interval.
    ///
    /// - Parameter timeInterval: The time in seconds.
    init(timeInterval: TimeInterval) {
        self.init(seconds: timeInterval, preferredTimescale: 1000000000)
    }
    
    //swiftlint:disable variable_name
    /// Returns the TimerInterval value of CMTime (only if it's a valid value).
    var ap_timeIntervalValue: TimeInterval? {
        if flags.contains(.valid) {
            let seconds = CMTimeGetSeconds(self)
            if !seconds.isNaN {
                return TimeInterval(seconds)
            }
        }
        return nil
    }
}

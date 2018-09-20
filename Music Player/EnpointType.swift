//
//  EnpointType.swift
//  Music Player
//
//  Created by Даниил on 20.09.2018.
//  Copyright © 2018 polat. All rights reserved.
//

import Foundation

protocol EndPointType {
    static var baseUrl: String { get }
    var parameters: [String:Any] { get }
}

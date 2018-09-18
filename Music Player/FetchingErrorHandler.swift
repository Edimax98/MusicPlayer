//
//  FetchingErrorHandler.swift
//  Music Player
//
//  Created by Даниил on 18.09.2018.
//  Copyright © 2018 polat. All rights reserved.
//

import Foundation

protocol FetchingErrorHandler {
    
    func fetchingEndedWithError(_ error: Error)
}

//
//  PaidSubscription.swift
//  Music Player
//
//  Created by Даниил on 13.09.2018.
//  Copyright © 2018 polat. All rights reserved.
//

import Foundation

private let dateFormatter: DateFormatter = {
   let df = DateFormatter()
    df.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
    return df
}()

struct PaidSubscription {
    
    public enum Level {
        case one
        case all
        
        init?(productId: String) {
            if productId.contains("allaccess") {
                self = .all
            } else {
                return nil
            }
        }
    }
    
    public let productId: String
    public let purchaseDate: Date
    public let expiresDate: Date
    public var isTrial: Bool
    public var isEligibleForTrial = true
    public let level: Level = .all
    
    public var isActive: Bool {
        return (purchaseDate...expiresDate).contains(Date())
    }
    
    init(productId: String, purchaseDateString: String, expiresDateString: String, isTrial: String) {
        
        if let purchaseDate = dateFormatter.date(from: purchaseDateString),
            let expiresDate = dateFormatter.date(from: expiresDateString) {
            self.purchaseDate = purchaseDate
            self.expiresDate = expiresDate
        } else {
            self.purchaseDate = Date()
            self.expiresDate = Date()
        }
        
        self.productId = productId
        self.isTrial = (isTrial == "true") ? true : false
    }
}

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
            //if productId.contains("week") {
                //self = .one
           // } else
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
    public let level: Level
    
    public var isActive: Bool {
        return (purchaseDate...expiresDate).contains(Date())
    }
    
    init?(json: [String: Any]) {
        guard
            let productId = json["product_id"] as? String,
            let purchaseDateString = json["purchase_date"] as? String,
            let purchaseDate = dateFormatter.date(from: purchaseDateString),
            let expiresDateString = json["expires_date"] as? String,
            let expiresDate = dateFormatter.date(from: expiresDateString)
            else {
                return nil
        }
        
        self.productId = productId
        self.purchaseDate = purchaseDate
        self.expiresDate = expiresDate
        self.level = Level(productId: productId) ?? .all // if we've botched the productId give them all access :]
    }
}

//
//  Session.swift
//  Music Player
//
//  Created by Даниил on 13.09.2018.
//  Copyright © 2018 polat. All rights reserved.
//

import Foundation

struct Session {
    
    let id: SessionId
    let paidSubscriptions: [PaidSubscription]
    
    public var currentSubscription: PaidSubscription? {
        let activeSubscriptions = paidSubscriptions.filter { $0.isActive && $0.purchaseDate >= SubscriptionNetworkService.shared.simulatedStartDate }
        let sortedByMostRecentPurchase = activeSubscriptions.sorted { $0.purchaseDate > $1.purchaseDate }
        
        return sortedByMostRecentPurchase.first
    }
    
    public var receiptData: Data
    public var parsedReceipt: [String: Any]
    
    init(receiptData: Data, parsedReceipt: [String: Any]) {
        id = UUID().uuidString
        self.receiptData = receiptData
        self.parsedReceipt = parsedReceipt
        
        if let receipt = parsedReceipt["receipt"] as? [String: Any], let purchases = receipt["in_app"] as? Array<[String: Any]> {
            var subscriptions = [PaidSubscription]()
            for purchase in purchases {
                if let paidSubscription = PaidSubscription(json: purchase) {
                    subscriptions.append(paidSubscription)
                }
            }
            paidSubscriptions = subscriptions
        } else {
            paidSubscriptions = []
        }
    }
}

extension Session: Equatable {
    public static func ==(lhs: Session, rhs: Session) -> Bool {
        return lhs.id == rhs.id
    }
}

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
        var current = activeSubscriptions.last
        
        paidSubscriptions.forEach {
            if $0.isTrial == "true" {
                current?.isEligibleForTrial = false
            }
        }
        return current
    }
    
    public var isEligibleForTrial: Bool {
        
        for sub in paidSubscriptions {
            if sub.isTrial == "true" && paidSubscriptions.count != 1 {
                return false
            }
        }
        return true
    }
    
    public var receiptData: Data
    public var parsedReceipt: [String: Any]
    
    init(receiptData: Data, parsedReceipt: [String: Any]) {
        id = UUID().uuidString
        self.receiptData = receiptData
        self.parsedReceipt = parsedReceipt
        print(parsedReceipt)
        if let purchases = parsedReceipt["latest_receipt_info"] as? Array<[String: Any]> {
            var subscriptions = [PaidSubscription]()
            for purchase in purchases {
                print(purchase)
                print("---------")
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

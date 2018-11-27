//
//  Session.swift
//  Music Player
//
//  Created by Даниил on 13.09.2018.
//  Copyright © 2018 polat. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Session {
    
    let id: SessionId
    let paidSubscriptions: [PaidSubscription]
    public var receiptData: Data
    public var parsedReceipt: [String: Any]
    
    public var currentSubscription: PaidSubscription? {
        let activeSubscriptions = paidSubscriptions.filter { $0.isActive && $0.purchaseDate >= SubscriptionNetworkService.shared.simulatedStartDate }
        var current = activeSubscriptions.last
        
        paidSubscriptions.forEach {
            if $0.isTrial == true {
                current?.isEligibleForTrial = false
            }
        }
        return current
    }
    
    public var isEligibleForTrial: Bool {
        
        for sub in paidSubscriptions {
            if sub.isTrial == true && paidSubscriptions.count != 1 {
                UserDefaults.standard.set(true, forKey: "isTrialExpired")
                return false
            }
        }
        UserDefaults.standard.set(false, forKey: "isTrialExpired")
        return true
    }
    
    init(receiptData: Data, parsedReceipt: [String: Any]) {
        id = UUID().uuidString
        self.receiptData = receiptData
        self.parsedReceipt = parsedReceipt
        
        if let purchases = JSON(parsedReceipt)["latest_receipt_info"].array {
            var subscriptions = [PaidSubscription]()
            for purchase in purchases {
                    let paidSubscription = PaidSubscription(productId: purchase["product_id"].stringValue,
                                                            purchaseDateString: purchase["purchase_date"].stringValue,
                                                            expiresDateString: purchase["expires_date"].stringValue,
                                                            isTrial: purchase["is_trial_period"].stringValue)
                    subscriptions.append(paidSubscription)
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

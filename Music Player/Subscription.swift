//
//  Subscription.swift
//  Music Player
//
//  Created by Даниил on 13.09.2018.
//  Copyright © 2018 polat. All rights reserved.
//

import Foundation
import StoreKit

private var formatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.formatterBehavior = .behavior10_4
    
    return formatter
}()

struct Subscription {

    var product: SKProduct
    var formattedPrice: String
    var currencyCode: String
    var priceWithoutCurrency: Double
    
    init(product: SKProduct) {
                
        self.product = product
        
        if formatter.locale != self.product.priceLocale {
            formatter.locale = self.product.priceLocale
        }
        currencyCode = self.product.priceLocale.currencyCode ?? ""
        priceWithoutCurrency = self.product.price.doubleValue
        formattedPrice = formatter.string(from: product.price) ?? "\(product.price)"
    }
}

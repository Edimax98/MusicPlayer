//
//  AppDelegate.swift
//  Music Player
//
//  Created by polat on 19/08/14.
//  Copyright (c) 2014 polat. All rights reserved.
// contact  bpolat@live.com


import UIKit
import StoreKit
import FacebookCore
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        SubscriptionService.shared.loadSubscriptionOptions()
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        AppEventsLogger.activate(application)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
        return handled
    }
}

extension AppDelegate: SKPaymentTransactionObserver {
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                handlePurchasingState(for: transaction, in: queue)
            case .purchased:
                handlePurchasedState(for: transaction, in: queue)
            case .restored:
                handleRestoredState(for: transaction, in: queue)
            case .failed:
                handleFailedState(for: transaction, in: queue)
            case .deferred:
                handleDeferredState(for: transaction, in: queue)
            }
        }
    }
    
    func handlePurchasingState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        print("User is attempting to purchase product id: \(transaction.payment.productIdentifier)")
    }
    
    func handlePurchasedState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        print("User purchased product id: \(transaction.payment.productIdentifier)")
        
        queue.finishTransaction(transaction)
        SubscriptionService.shared.uploadReceipt { (success) in
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: SubscriptionService.purchaseSuccessfulNotification, object: nil)
            }
        }
    }
    
    func handleRestoredState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        print("Purchase restored for product id: \(transaction.payment.productIdentifier)")
        queue.finishTransaction(transaction)
        SubscriptionService.shared.uploadReceipt { (success) in
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: SubscriptionService.restoreSuccessfulNotification, object: nil)
            }
        }
    }
    
    func handleFailedState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        print("Purchase failed for product id: \(transaction.payment.productIdentifier)")
    }
    
    func handleDeferredState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        print("Purchase deferred for product id: \(transaction.payment.productIdentifier)")
    }
}


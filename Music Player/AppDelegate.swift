//
//  AppDelegate.swift
//  Music Player
//
//  Created by polat on 19/08/14.
//  Copyright (c) 2014 polat. All rights reserved.
// contact  bpolat@live.com


import UIKit
import StoreKit
import MediaPlayer
import FacebookCore
import FBSDKCoreKit
import FBAudienceNetwork

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    private func setupRootController() {
        
        let mainView = MusicPlayerLandingPage.controllerInStoryboard(UIStoryboard(name: "Main", bundle: nil))
        let subscriptionInfoView = SubscriptionInfoViewController.controllerInStoryboard(UIStoryboard(name: "SubscriptionInfoViewController", bundle: nil))
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.rootViewController = mainView
        
        SubscriptionService.shared.loadSubscriptionOptions()
        guard SubscriptionService.shared.hasReceiptData else {
            self.window?.rootViewController = subscriptionInfoView
            return
        }
        
        SubscriptionService.shared.uploadReceipt { (success,shouldRetry) in
            if success {
                guard SubscriptionService.shared.currentSubscription != nil else {
                    self.window?.rootViewController = subscriptionInfoView
                    NotificationCenter.default.post(name: SubscriptionService.noSubscriptionAfterAutoCheckNotification, object: self)
                    return
                }
                mainView.accessStatus = .available
            } else if !shouldRetry {
                self.window?.rootViewController = subscriptionInfoView
            } else if shouldRetry {
                SubscriptionService.shared.uploadReceipt { (success, _) in
                    if success {
                        guard SubscriptionService.shared.currentSubscription != nil else {
                            self.window?.rootViewController = subscriptionInfoView
                            NotificationCenter.default.post(name: SubscriptionService.noSubscriptionAfterAutoCheckNotification, object: self)
                            return
                        }
                        mainView.accessStatus = .available
                    } else {
                        self.window?.rootViewController = subscriptionInfoView
                    }
                }
            }
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        SKPaymentQueue.default().add(self)
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        
        let option = DeepLinkOption.build(with: userActivity)
        DeepLinkNavigator.shared.proceed(with: option)
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        AppEventsLogger.activate(application)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
        return handled
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        SKPaymentQueue.default().remove(self)
    }
}

extension AppDelegate: SKPaymentTransactionObserver {
    
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        
        if queue.transactions.isEmpty {
            NotificationCenter.default.post(name: SubscriptionService.nothingToRestoreNotification, object: nil)
        }
    }
    
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
                print(transaction.error?.localizedDescription ?? "")
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
        SubscriptionService.shared.uploadReceipt { (success, shouldRetry) in
            if success {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: SubscriptionService.purchaseSuccessfulNotification, object: nil)
                }
            } else {
                SubscriptionService.shared.uploadReceipt { (success, _) in
                    guard success else { return }
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: SubscriptionService.purchaseSuccessfulNotification, object: nil)
                    }
                }
            }
        }
    }
    
    func handleRestoredState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        print("Purchase restored for product id: \(transaction.payment.productIdentifier)")
        queue.finishTransaction(transaction)
        SubscriptionService.shared.uploadReceipt { (success, shouldRetry) in
            if success {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: SubscriptionService.restoreSuccessfulNotification, object: nil)
                }
            } else {
                SubscriptionService.shared.uploadReceipt { (success, _) in
                    guard success else { return }
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: SubscriptionService.purchaseSuccessfulNotification, object: nil)
                    }
                }
            }
        }
    }
    
    func handleFailedState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        print("Purchase failed for product id: \(transaction.payment.productIdentifier)")
        queue.finishTransaction(transaction)
        NotificationCenter.default.post(name: SubscriptionService.purchaseFailedNotification, object: nil)
    }
    
    func handleDeferredState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        print("Purchase deferred for product id: \(transaction.payment.productIdentifier)")
        queue.finishTransaction(transaction)
    }
}


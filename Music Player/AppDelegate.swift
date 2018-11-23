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
    
    private let mainView = MusicPlayerLandingPage.controllerInStoryboard(UIStoryboard(name: "Main", bundle: nil))
    private let subscriptionInfoView = SubscriptionInfoViewController.controllerInStoryboard(UIStoryboard(name: "SubscriptionInfoViewController", bundle: nil))
    
    private func uploadRecieptSucceeded() {
        guard SubscriptionService.shared.currentSubscription != nil else {
            self.window?.rootViewController = self.subscriptionInfoView
            NotificationCenter.default.post(name: SubscriptionService.noSubscriptionAfterAutoCheckNotification, object: self)
            return
        }
        self.mainView.accessState = .available
        self.mainView.accessStatusChanged(to: .available)
    }
    
    private func tryAgainToUploadReciept() {
        SubscriptionService.shared.uploadReceipt { (success, _) in
            if success {
                self.uploadRecieptSucceeded()
            } else {
                self.window?.rootViewController = self.subscriptionInfoView
            }
        }
    }
    
    private func setupRootController() {
        
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
                self.uploadRecieptSucceeded()
            } else if shouldRetry {
                self.tryAgainToUploadReciept()
            } else if !shouldRetry {
                self.window?.rootViewController = self.subscriptionInfoView
            }
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        SKPaymentQueue.default().add(self)
        //setupRootController()
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        DeepLinker.checkDeeplink()
        AppEventsLogger.activate(application)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        let _ = DeepLinker.handleDeeplink(url: url)
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


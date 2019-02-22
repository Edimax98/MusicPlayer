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
import FBSDKCoreKit.FBSDKAppLinkUtility

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    weak var accessHandler: AccessHandler?
    
    private let mainView = MusicPlayerLandingPage.controllerInStoryboard(UIStoryboard(name: "Main", bundle: nil))
    private let subscriptionInfoView = SubscriptionInfoViewController.controllerInStoryboard(UIStoryboard(name: "SubscriptionInfoViewController", bundle: nil))
    
    private func uploadRecieptSucceeded() {
        guard SubscriptionService.shared.currentSubscription != nil else {
            self.mainView.showSubscriptionOffer()
            NotificationCenter.default.post(name: SubscriptionService.noSubscriptionAfterAutoCheckNotification, object: self)
            return
        }
        self.mainView.accessState = .available
        self.mainView.accessStatusChanged(to: .available)
    }
    
    private func tryToUploadReciept() {
        SubscriptionService.shared.uploadReceipt { (success, _) in
            if success {
                self.uploadRecieptSucceeded()
            } else {
                self.mainView.showSubscriptionOffer()
            }
        }
    }
    
    private func uploadSucceededAfterDeeplink(with url: URL) {
        
        let _ =  DeepLinker.handleDeeplink(url: url)
        DeepLinker.checkDeeplink()
        
        guard SubscriptionService.shared.currentSubscription != nil else {
            DeepLinkNavigator.shared.dataLoaded = { [weak self] in
                self?.mainView.showSubscriptionOffer()
            }
            return
        }
        self.mainView.accessState = .available
        self.mainView.accessStatusChanged(to: .available)
    }
    
    private func tryToUploadAfterDeeplink(with url: URL) {
        
        SubscriptionService.shared.uploadReceipt { (success, _) in
            if success {
                self.uploadSucceededAfterDeeplink(with: url)
            } else {
                let _ = DeepLinker.handleDeeplink(url: url)
                DeepLinker.checkDeeplink()
                DeepLinkNavigator.shared.dataLoaded = { [weak self] in
                    self?.mainView.showSubscriptionOffer()
                }
            }
        }
    }
    
    private func setupRootController() {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.rootViewController = mainView
        
        SubscriptionService.shared.loadSubscriptionOptions()
        
        guard SubscriptionService.shared.hasReceiptData else {
            self.mainView.showSubscriptionOffer()
            return
        }

		SubscriptionService.shared.uploadReceipt { (success,shouldRetry) in
            if success {
                self.uploadRecieptSucceeded()
            } else if shouldRetry {
                self.tryToUploadReciept()
            } else if !shouldRetry {
                self.mainView.showSubscriptionOffer()
            }
        }
    }
    
    // MARK: App life cycle
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        SKPaymentQueue.default().add(self)
		
//        if UserDefaults.standard.bool(forKey: "wereWelcomePagesShown") {
//            setupRootController()
//        } else {
			
			window = UIWindow(frame: UIScreen.main.bounds)
			window?.makeKeyAndVisible()
			//window?.rootViewController = WelcomePagesViewController.controllerInStoryboard(UIStoryboard(name: "Main", bundle: nil))
            window?.rootViewController = GenreTestViewController.controllerInStoryboard(UIStoryboard(name: "Main", bundle: nil))
			
//            guard let welcomePagesVc = window?.rootViewController as? WelcomePagesViewController else {
//                return true
//            }
//
//            accessHandler = welcomePagesVc
//            let subOfferVc = SubscriptionInfoViewController.controllerInStoryboard(UIStoryboard(name: "SubscriptionInfoViewController", bundle: nil))
//            welcomePagesVc.welcomePagesSkipped = { [weak self] in
//                guard let unwrappedSelf = self else { return }
//                SubscriptionService.shared.loadSubscriptionOptions()
//                unwrappedSelf.window?.rootViewController = subOfferVc
//            }
//        }
		
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        AppEventsLogger.activate(application)
        FBSDKAppLinkUtility.fetchDeferredAppLink { (url, error) in
            
            if let unwrappedError = error {
                print("Error after deffered deeplink - \(unwrappedError)")
            } else {
                guard let unwrappedUrl = url else { print("URL after deffered deeplink is nil"); return }
                
                guard SubscriptionService.shared.hasReceiptData else {
                    let _ = DeepLinker.handleDeeplink(url: unwrappedUrl)
                    DeepLinker.checkDeeplink()
                    self.mainView.showSubscriptionOffer()
                    return
                }
                
                SubscriptionService.shared.uploadReceipt { (success, shouldRetry) in
                    if success {
                        self.uploadSucceededAfterDeeplink(with: unwrappedUrl)
                    } else if shouldRetry {
                        self.tryToUploadAfterDeeplink(with: unwrappedUrl)
                    } else if !shouldRetry {
                        let _ = DeepLinker.handleDeeplink(url: unwrappedUrl)
                        DeepLinker.checkDeeplink()
                        self.mainView.showSubscriptionOffer()
                    }
                }
            }
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        let handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
        
        guard SubscriptionService.shared.hasReceiptData else {
            let _ = DeepLinker.handleDeeplink(url: url)
            DeepLinker.checkDeeplink()
            mainView.showSubscriptionOffer()
            return handled
        }
        
        SubscriptionService.shared.uploadReceipt { (success, shouldRetry) in
            if success {
                self.uploadSucceededAfterDeeplink(with: url)
            } else if shouldRetry {
                self.tryToUploadAfterDeeplink(with: url)
            } else if !shouldRetry {
                let _ = DeepLinker.handleDeeplink(url: url)
                DeepLinker.checkDeeplink()
                self.mainView.showSubscriptionOffer()
            }
        }
        return handled
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        SKPaymentQueue.default().remove(self)
        UserDefaults.standard.removeObject(forKey: "isTrialExpired")
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
    
    fileprivate func logEvents() {
        
        SubscriptionService.shared.loadSubscriptionOptions()
        SubscriptionService.shared.optionsLoaded = { option in
            if SubscriptionService.shared.isEligibleForTrial && SubscriptionService.shared.currentSubscription != nil {
                FBSDKAppEvents.logEvent(FBSDKAppEventNameInitiatedCheckout,
                                        parameters: [FBSDKAppEventParameterNameContentType: "3 days trial",
                                                     FBSDKAppEventParameterNameContentID: option.product.productIdentifier,
                                                     FBSDKAppEventParameterNameDescription: FacebookEventsEviroment.shared.enviroment.rawValue])
                
            }
            if SubscriptionService.shared.isEligibleForTrial == false {
                FBSDKAppEvents.logPurchase(option.priceWithoutCurrency, currency: option.currencyCode,
                                           parameters: [FBSDKAppEventParameterNameContentType: "Weekly subscription",
                                                        FBSDKAppEventParameterNameContentID: option.product.productIdentifier,
                                                        FBSDKAppEventParameterNameDescription: FacebookEventsEviroment.shared.enviroment.rawValue])
            }
        }
    }
    
    func handlePurchasedState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        print("User purchased product id: \(transaction.payment.productIdentifier)")
        queue.finishTransaction(transaction)
        SubscriptionService.shared.uploadReceipt { (success, shouldRetry) in
            if success {
                self.logEvents()
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: SubscriptionService.purchaseSuccessfulNotification, object: nil)
                }
            } else if shouldRetry {
                SubscriptionService.shared.uploadReceipt { (success, _) in
                    guard success else { return }
                    self.logEvents()
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
            } else if shouldRetry {
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


//
//  SubscriptionInfoViewController.swift
//  Music Player
//
//  Created by Даниил on 23/10/2018.
//  Copyright © 2018 polat. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import SafariServices

class SubscriptionInfoViewController: UIViewController {
    
    @IBOutlet weak var restorePurchaseButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var featuresTitleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var trialLabel: UILabel!
    @IBOutlet weak var trialTermsLabel: UILabel!
    
    var subscription: Subscription?
    var status = AccessStatus.denied
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleRestoreSuccessfull(notification:)),
                                               name: SubscriptionService.restoreSuccessfulNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handlePurchaseSuccessfull(notification:)),
                                               name: SubscriptionService.purchaseSuccessfulNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleOptionsLoaded(notification:)),
                                               name: SubscriptionService.optionsLoadedNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(nothingToRestore(notification:)),
                                               name: SubscriptionService.nothingToRestoreNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(noSubscriptionsAfterAutiCheck),
                                               name: SubscriptionService.noSubscriptionAfterAutoCheckNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handlePurchaseFailed),
                                               name: SubscriptionService.purchaseFailedNotification,
                                               object: nil)
        
        if UserDefaults.standard.bool(forKey: "isTrialExpired") {
            self.trialLabel.text = "All access".localized
            guard let price = SubscriptionService.shared.options?.first?.formattedPrice else { return }
            self.priceLabel.text = "Your trial period has expired. ".localized + "Subscription price - ".localized + price
        }
        
        self.trialTermsLabel.text = "Payment will be charged to your iTunes Account at confirmation of purchase. Subscriptions will automatically renew unless canceled within 24-hours before the end of the current period. You can cancel anytime with your iTunes account settings. Any unused portion of a free trial will be forfeited if you purchase a subscription.".localized
    }
    
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "openMainPage" {
            
            if let destinationVc = segue.destination as? MusicPlayerLandingPage {
                destinationVc.wasSubscriptionSkipped = true
                if self.status == .available {
                    destinationVc.accessStatus = .available
                }
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func showErrorAlert(for error: SubscriptionServiceError) {
        let title: String
        let message: String
        
        switch error {
        case .missingAccountSecret, .invalidSession, .internalError:
            title = "Internal error".localized
            message = "Please try again.".localized
        case .noActiveSubscription:
            title = "No Active Subscription".localized
            message = "Please verify that you have an active subscription".localized
        case .other(let otherError):
            title = "Unexpected Error".localized
            message = otherError.localizedDescription
        case .wrongEnviroment: return
        case .purchaseFailed:
            title = "Purchase failed".localized
            message = "Purchase transaction failed. Try again"
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let backAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(backAction)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func restorePurchasesButtonPressed(_ sender: Any) {
        SubscriptionService.shared.restorePurchases()
    }
    
    @IBAction func skipButtonPressed(_ sender: Any) {
        FBSDKAppEvents.logEvent("User skipped subscription offer", parameters: [:])
    }

    @IBAction func startSubscriptionButtonPressed(_ sender: Any) {
        subscription = SubscriptionService.shared.options?.first
        guard let option = subscription else {
            showErrorAlert(for: .internalError)
            return
        }
        SubscriptionService.shared.purchase(subscription: option)
    }
    
    @IBAction func termOfServiceButtonPressed(_ sender: Any) {
        guard let url = URL(string: "http://indiesound.org/terms") else { return }
        let webView = SFSafariViewController(url: url)
        present(webView, animated: true, completion: nil)
    }
    
    @IBAction func privacyPolicyButtonPressed(_ sender: Any) {
        guard let url = URL(string: "http://indiesound.org/policy") else { return }
        let webView = SFSafariViewController(url: url)
        present(webView, animated: true, completion: nil)
    }
    
    @objc func handlePurchaseSuccessfull(notification: Notification) {
        
        guard let subscription = subscription else { return }
        
        if let _ = SubscriptionService.shared.currentSubscription {
            if !SubscriptionService.shared.isEligibleForTrial {
                self.trialLabel.text = "All access".localized
                self.priceLabel.text = "Your trial period has expired. ".localized + "Subscription price - ".localized + subscription.formattedPrice

                FBSDKAppEvents.logPurchase(subscription.priceWithoutCurrency, currency: subscription.currencyCode,
                                           parameters: [FBSDKAppEventParameterNameContentType: "Weekly subscription",
                                                        FBSDKAppEventParameterNameContentID: subscription.product.productIdentifier])
            } else {
                FBSDKAppEvents.logPurchase(0.0, currency: "",
                                           parameters: [FBSDKAppEventParameterNameContentType: "3 days trial",
                                                        FBSDKAppEventParameterNameContentID: subscription.product.productIdentifier])
            }
            status = .available
        }
    }
    
    @objc func handleRestoreSuccessfull(notification: Notification) {
        
        guard let subscription = subscription else { return }
        
        if !SubscriptionService.shared.isEligibleForTrial {
            trialLabel.text = "All access".localized
            self.priceLabel.text = "Your trial period has expired. ".localized + "Subscription price - ".localized + subscription.formattedPrice
        }
        
        if SubscriptionService.shared.currentSubscription != nil {
            let alert = UIAlertController(title: "Successfull".localized, message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                self.performSegue(withIdentifier: "openMainPage", sender: self)
            }
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
            status = .available
        } else {
            showErrorAlert(for: .noActiveSubscription)
        }
    }
    
    @objc func noSubscriptionsAfterAutiCheck() {
        
        guard let subscription = subscription else { return }
        
        if !SubscriptionService.shared.isEligibleForTrial {
                self.trialLabel.text = "All access".localized
                self.priceLabel.text = "Your trial period has expired. ".localized + "Subscription price - ".localized + subscription.formattedPrice
            UserDefaults.standard.set(true, forKey: "isTrialExpired")
        }
    }
    
    @objc func handleOptionsLoaded(notification: Notification) {
     
        guard let sub = SubscriptionService.shared.options?.first else {
            showErrorAlert(for: .internalError)
            return
        }
    
        self.subscription = sub
        self.trialTermsLabel.text = "Payment will be charged to your iTunes Account at confirmation of purchase. Subscriptions will automatically renew unless canceled within 24-hours before the end of the current period. You can cancel anytime with your iTunes account settings. Any unused portion of a free trial will be forfeited if you purchase a subscription.".localized
    }
    
    @objc func nothingToRestore(notification: Notification) {
        showErrorAlert(for: .noActiveSubscription)
    }
    
    @objc func handlePurchaseFailed() {
        
    }
}

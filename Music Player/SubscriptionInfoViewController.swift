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
    
    @IBOutlet weak var purchaseButton: UIButton!
    @IBOutlet weak var restorePurchaseButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var featuresTitleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var trialLabel: UILabel!
    @IBOutlet weak var trialTermsLabel: UILabel!
    @IBOutlet weak var AccesFeatureLabel: UILabel!
    @IBOutlet weak var authorsFeatureLabel: UILabel!
    @IBOutlet weak var adsFreeFeatureLabel: UILabel!
    @IBOutlet weak var featuresTitle: UILabel!
    @IBOutlet weak var termsButton: UIButton!
    @IBOutlet weak var policyButton: UIButton!
    
    var subscription: Subscription?
    var status = AccessState.denied
    fileprivate let trialExpiredMessage = "Your trial period has expired. Subscription price - ".localized
    fileprivate let trialAvailableMessage = "3 days trial. Subscription price - ".localized
    fileprivate let disclaimerMessage = "Payment will be charged to your iTunes Account at confirmation of purchase. Subscriptions will automatically renew unless canceled within 24-hours before the end of the current period. Subscription auto-renewal may be turned off by going to the Account Settings after purchase. Any unused portion of a free trial will be forfeited when you purchase a subscription.".localized
    fileprivate let allAccessMessage = "All access".localized
    fileprivate let freeTrialMessage = "3 days for FREE".localized
    fileprivate let subscriptionDuration = " per week".localized
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
		
        AccesFeatureLabel.text = "Full access to 400 000 songs".localized
        authorsFeatureLabel.text = "The best indie authors".localized
        adsFreeFeatureLabel.text = "Ads free".localized
        trialTermsLabel.text = disclaimerMessage
        featuresTitle.text = "Features".localized
        
        restorePurchaseButton.setTitle("restore".localized, for: .normal)
        skipButton.setTitle("skip".localized, for: .normal)
        purchaseButton.setTitle("START".localized, for: .normal)
        termsButton.setTitle("Terms of Service".localized, for: .normal)
        policyButton.setTitle("Privacy Policy".localized, for: .normal)
        
        if UserDefaults.standard.bool(forKey: "isTrialExpired") == true {
            self.trialLabel.text = allAccessMessage
            guard let price = SubscriptionService.shared.options?.first?.formattedPrice else { return }
            self.priceLabel.text = trialExpiredMessage + price + subscriptionDuration
        } else {
            self.trialLabel.text = freeTrialMessage
            guard let price = SubscriptionService.shared.options?.first?.formattedPrice else { return }
            self.priceLabel.text = trialAvailableMessage + price + subscriptionDuration
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "unwindToMain" || segue.identifier == "openMainPage" {
            if let destinationVc = segue.destination as? MusicPlayerLandingPage {
                destinationVc.wasSubscriptionSkipped = true
                if self.status == .available {
                    destinationVc.accessState = .available
                    destinationVc.accessStatusChanged(to: .available)
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
        let backAction = UIAlertAction(title:"OK", style: .default)
        alert.addAction(backAction)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func restorePurchasesButtonPressed(_ sender: Any) {
        SubscriptionService.shared.restorePurchases()
    }
    
    @IBAction func skipButtonPressed(_ sender: Any) {
        FBSDKAppEvents.logEvent("User skipped subscription offer", parameters: [FBSDKAppEventParameterNameDescription: FacebookEventsEviroment.shared.enviroment.rawValue])
    
        if let _ = self.parent as? MusicPlayerLandingPage {
            performSegue(withIdentifier: "unwindToMain", sender: self)
        } else {
            performSegue(withIdentifier: "openMainPage", sender: self)
        }
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
        guard let url = URL(string: "https://sfbtech.org/terms") else { return }
        let webView = SFSafariViewController(url: url)
        present(webView, animated: true, completion: nil)
    }
    
    @IBAction func privacyPolicyButtonPressed(_ sender: Any) {
        guard let url = URL(string: "https://sfbtech.org/policy") else { return }
        let webView = SFSafariViewController(url: url)
        present(webView, animated: true, completion: nil)
    }
    
    @objc func handlePurchaseSuccessfull(notification: Notification) {
        
        guard let subscription = SubscriptionService.shared.options?.first else { return }

        if let _ = SubscriptionService.shared.currentSubscription {
            if !SubscriptionService.shared.isEligibleForTrial {
                self.trialLabel.text = allAccessMessage
                self.priceLabel.text = trialExpiredMessage + subscription.formattedPrice + subscriptionDuration
            } else {
                self.trialLabel.text = allAccessMessage
                self.priceLabel.text = trialAvailableMessage + subscription.formattedPrice + subscriptionDuration
            }
            status = .available
        }
    }
    
    @objc func handleRestoreSuccessfull(notification: Notification) {
        
        if SubscriptionService.shared.currentSubscription != nil {
            let alert = UIAlertController(title: "Successfull".localized, message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                self.performSegue(withIdentifier: "unwindToMain", sender: self)
            }
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
            status = .available
        } else {
            showErrorAlert(for: .noActiveSubscription)
        }
    }
    
    @objc func noSubscriptionsAfterAutiCheck() {
    }
    
    @objc func handleOptionsLoaded(notification: Notification) {
     
        guard let sub = SubscriptionService.shared.options?.first else {
            showErrorAlert(for: .internalError)
            return
        }

        self.subscription = sub

        if UserDefaults.standard.bool(forKey: "isTrialExpired") {
            self.trialLabel.text = allAccessMessage
            guard let price = SubscriptionService.shared.options?.first?.formattedPrice else { return }
            self.priceLabel.text = trialExpiredMessage + price + subscriptionDuration
        } else {
            self.trialLabel.text = freeTrialMessage
            guard let price = SubscriptionService.shared.options?.first?.formattedPrice else { return }
            self.priceLabel.text = trialAvailableMessage + price + subscriptionDuration
        }
    }
    
    @objc func nothingToRestore(notification: Notification) {
        showErrorAlert(for: .noActiveSubscription)
    }
    
    @objc func handlePurchaseFailed() {
        let alertController = UIAlertController(title: "Cannot connect to iTunes", message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        if presentedViewController != nil {
            alertController.dismiss(animated: false, completion: {
                self.present(alertController, animated: true, completion: nil)
            })
        } else {
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

//
//  SubscriptionInfoViewController.swift
//  Music Player
//
//  Created by Даниил on 23/10/2018.
//  Copyright © 2018 polat. All rights reserved.
//

import UIKit

class SubscriptionInfoViewController: UIViewController {
    
    @IBOutlet weak var restorePurchaseButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var featuresTitleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var trialLabel: UILabel!
    
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
    
        guard let price = SubscriptionService.shared.options?.first?.formattedPrice else { return }
        self.priceLabel.text = "3 days free trial. Subscription price ".localized + price
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
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let backAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(backAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func showRestoreAlert() {
        let alert = UIAlertController(title: "Subscription Issue", message: "We are having a hard time finding your subscription. If you've recently reinstalled the app or got a new device please restore your purchase. Otherwise press subscribe".localized, preferredStyle: .alert)
        
        let backAction = UIAlertAction(title: "Back".localized, style: .cancel)
        alert.addAction(backAction)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func restorePurchasesButtonPressed(_ sender: Any) {
        SubscriptionService.shared.restorePurchases()
    }
    
    @IBAction func skipButtonPressed(_ sender: Any) {
        
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
    
    }
    
    @IBAction func privacyPolicyButtonPressed(_ sender: Any) {
    
    }
    
    @objc func handlePurchaseSuccessfull(notification: Notification) {
        
        if let currentSub = SubscriptionService.shared.currentSubscription {
            if currentSub.isEligibleForTrial {
                self.trialLabel.text = "All access".localized
            }
            status = .available
        } else {
            showErrorAlert(for: .noActiveSubscription)
        }
    }
    
    @objc func handleRestoreSuccessfull(notification: Notification) {
        
        if !SubscriptionService.shared.isEligibleForTrial {
            trialLabel.text = "All access".localized
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
    
    @objc func handleOptionsLoaded(notification: Notification) {
        guard let sub = SubscriptionService.shared.options?.first else {
            showErrorAlert(for: .internalError)
            return
        }
        self.subscription = sub
        self.priceLabel.text = "3 days free trial. Subscription price ".localized + sub.formattedPrice
    }
}

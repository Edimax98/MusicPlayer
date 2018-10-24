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
                                               selector: #selector(handleOptionsLoaded(notification:)),
                                               name: SubscriptionService.optionsLoadedNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handlePurchaseSuccessfull(notification:)),
                                               name: SubscriptionService.purchaseSuccessfulNotification,
                                               object: nil)
//        /NotificationCenter.default.addObserver(self,
//                                               selector: #selector(handleRestoreSuccessfull(notification:)),
//                                               name: SubscriptionService.restoreSuccessfulNotification,
//                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func restorePurchasesButtonPressed(_ sender: Any) {
        SubscriptionService.shared.restorePurchases()
    }
    
    @IBAction func skipButtonPressed(_ sender: Any) {
    
    }

    @IBAction func startSubscriptionButtonPressed(_ sender: Any) {
        subscription = SubscriptionService.shared.options?.first
        guard let option = subscription else { return }
        SubscriptionService.shared.purchase(subscription: option)
    }
    
    @IBAction func termOfServiceButtonPressed(_ sender: Any) {
    
    }
    
    @IBAction func privacyPolicyButtonPressed(_ sender: Any) {
    
    }
    
    @objc func handleOptionsLoaded(notification: Notification) {
        DispatchQueue.main.async { [weak self] in
      
        }
    }
    
    @objc func handlePurchaseSuccessfull(notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.status = .available
        }
        
        print(SubscriptionService.shared.currentSubscription)
        self.priceLabel.text = "3 days free trial. Subscription price ".localized + SubscriptionService.shared.options!.first!.formattedPrice
        if let currentSub = SubscriptionService.shared.currentSubscription {
            print(currentSub)
//            if !currentSub.isTrial {
//                self.trialLabel.text = "All access".localized
//            }
        }
    }
    
    @objc func handleRestoreSuccessfull(notification: Notification) {
        
        let alert = UIAlertController(title: "You have successfully restored your purchases".localized, message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}

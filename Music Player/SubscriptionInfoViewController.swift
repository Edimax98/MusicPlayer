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

    var subscription: Subscription?
    var status = AccessStatus.denied
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subscription = SubscriptionService.shared.options?.first
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleOptionsLoaded(notification:)),
                                               name: SubscriptionService.optionsLoadedNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handlePurchaseSuccessfull(notification:)),
                                               name: SubscriptionService.purchaseSuccessfulNotification,
                                               object: nil)
        
        
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func restorePurchasesButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func skipButtonPressed(_ sender: Any) {
    
    }

    @IBAction func startSubscriptionButtonPressed(_ sender: Any) {
        
        guard let option = subscription else { return }
        SubscriptionService.shared.purchase(subscription: option)
    }
    
    @IBAction func termOfServiceButtonPressed(_ sender: Any) {
    
    }
    
    @IBAction func privacyPolicyButtonPressed(_ sender: Any) {
    
    }
    
    @objc func handleOptionsLoaded(notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            // self?.option = SubscriptionService.shared.options?.first!
        }
    }
    
    @objc func handlePurchaseSuccessfull(notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.status = .available
        }
        print("HELLO THERE")
    }
    
    
    
}

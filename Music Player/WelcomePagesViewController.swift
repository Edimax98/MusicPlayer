//
//  WelcomePagesViewController.swift
//  Music Player
//
//  Created by Даниил on 14/12/2018.
//  Copyright © 2018 polat. All rights reserved.
//

import UIKit
import paper_onboarding

protocol AccessHandler: class {
    func denyAccess()
    func openAccess()
}

class WelcomePagesViewController: UIViewController {

    @IBOutlet weak var nextButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var paperOnboardingView: PaperOnboarding!
	var welcomePagesSkipped: (() -> Void)?
    fileprivate var accessStatus = AccessState.denied
    fileprivate static let titleFont = UIFont(name: "Helvetica-Bold", size: 36.0) ?? UIFont.boldSystemFont(ofSize: 36.0)
    fileprivate static let descriptionFont = UIFont(name: "Helvetica-Regular", size: 25.0) ?? UIFont.systemFont(ofSize: 14.0)
    fileprivate static let backgroundColor = UIColor(red: 27 / 255, green: 29 / 255, blue: 73 / 255, alpha: 1.00)

    fileprivate let items = [
        OnboardingItemInfo(informationImage: UIImage(named: "headphones")!,
                           title: "The best indies".localized,
                           description: "Discover the best indie songs of 400 000 collection".localized,
                           pageIcon: UIImage(named: "melody_mini")!,
                           color: WelcomePagesViewController.backgroundColor,
                           titleColor: UIColor.white, descriptionColor: UIColor.white, titleFont: WelcomePagesViewController.titleFont, descriptionFont: WelcomePagesViewController.descriptionFont),

        OnboardingItemInfo(informationImage: UIImage(named: "nosong")!,
                           title: "Custom playlists".localized,
                           description: "Every day a fresh custom playlists. Each playlist was created by Indie Sound".localized,
                           pageIcon: UIImage(named: "play_mini")!,
                           color: WelcomePagesViewController.backgroundColor,
                           titleColor: UIColor.white, descriptionColor: UIColor.white, titleFont: WelcomePagesViewController.titleFont, descriptionFont: WelcomePagesViewController.descriptionFont),

        OnboardingItemInfo(informationImage: UIImage(named: "welcome_wave")!,
                           title: "Enjoy!".localized,
                           description: "Start your journey right now! With paid subscription you can avoid ads.".localized,
                           pageIcon: UIImage(named: "beat_mini")!,
                           color: WelcomePagesViewController.backgroundColor,
                           titleColor: UIColor.white, descriptionColor: UIColor.white, titleFont: WelcomePagesViewController.titleFont, descriptionFont: WelcomePagesViewController.descriptionFont)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPaperOnboardingView()
        view.bringSubview(toFront: skipButton)
        view.bringSubview(toFront: nextButton)
    }

    private func setupPaperOnboardingView() {
        
        skipButton.setTitle("skip".localized, for: .normal)
        nextButton.setTitle("NEXT".localized, for: .normal)
        nextButton.layer.cornerRadius = nextButton.frame.height / 2
        paperOnboardingView.dataSource = self
        paperOnboardingView.delegate = self
        for attribute: NSLayoutConstraint.Attribute in [.left, .right, .top, .bottom] {
            let constraint = NSLayoutConstraint(item: paperOnboardingView,
                                                attribute: attribute,
                                                relatedBy: .equal,
                                                toItem: view,
                                                attribute: attribute,
                                                multiplier: 1,
                                                constant: 0)
            view.addConstraint(constraint)
        }
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        
        if paperOnboardingView.currentIndex + 1 <= items.count - 1 {
            paperOnboardingView.currentIndex(paperOnboardingView.currentIndex + 1, animated: true)
        } else {
            UserDefaults.standard.set(true, forKey: "wereWelcomePagesShown")
            welcomePagesSkipped?()
        }
    }
    
    @IBAction func skipButtonPressed(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: "wereWelcomePagesShown")
        welcomePagesSkipped?()
    }
}

extension WelcomePagesViewController: PaperOnboardingDelegate {
 
    func onboardingWillTransitonToIndex(_: Int) {
        nextButtonBottomConstraint.constant = nextButton.frame.height
        nextButton.alpha = 0
        view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.8,
                       delay: 0,
                       options: .curveEaseOut, animations: {
                        self.nextButtonBottomConstraint.constant = 87
                        self.nextButton.alpha = 0
                        self.nextButton.alpha = 1
                        self.view.layoutIfNeeded()
        }, completion: nil)
    }
}

// MARK: PaperOnboardingDataSource
extension WelcomePagesViewController: PaperOnboardingDataSource {

    func onboardingItem(at index: Int) -> OnboardingItemInfo {
        return items[index]
    }

    func onboardingItemsCount() -> Int {
        return items.count
    }
}

extension WelcomePagesViewController: AccessHandler {
    
    func denyAccess() {
        accessStatus = .denied
    }
    
    func openAccess() {
        accessStatus = .available
    }
}

//
//  UIViewControllerExtension.swift
//  Music Player
//
//  Created by Даниил on 05/10/2018.
//  Copyright © 2018 polat. All rights reserved.
//

import UIKit

extension UIViewController {
    
    private class func instantiateControllerInStoryboard<T: UIViewController>(_ storyboard: UIStoryboard, identifier: String) -> T {
        return storyboard.instantiateViewController(withIdentifier: identifier) as! T
    }
    
    class func controllerInStoryboard(_ storyboard: UIStoryboard, identifier: String) -> Self {
        return instantiateControllerInStoryboard(storyboard, identifier: identifier)
    }
    
    class func controllerInStoryboard(_ storyboard: UIStoryboard) -> Self {
        return instantiateControllerInStoryboard(storyboard, identifier: nameOfClass)
    }
}

extension UIAlertController {
    
    class func displayLoadingAlert(on viewController: UIViewController) -> UIAlertController {
        let alert = UIAlertController(title: "Loading...", message: nil, preferredStyle: .alert)
        alert.view.tintColor = UIColor.black
        let spinner = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50)) as UIActivityIndicatorView
        spinner.hidesWhenStopped = true
        spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        spinner.startAnimating()
        alert.view.addSubview(spinner)
        return alert
    }
}

//
//  DisplayUI.swift
//  OpenJio
//
//  Created by Koh Jia Rong on 17/2/17.
//  Copyright © 2017 Koh Jia Rong. All rights reserved.
//

import Foundation
import UIKit

class DisplayUI: NSObject {
    override init() {
        super.init()
    }
    
    static func displayErrorMessage(_ message: String, hostViewController: UIViewController, activityIndicator: UIActivityIndicatorView?) {
        let alertVC = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        
        alertVC.addAction(action)
        
        DispatchQueue.main.async {
            activityIndicator?.stopAnimating()
            activityIndicator?.isHidden = true
            hostViewController.present(alertVC, animated: true, completion: nil)
        }
        
    }
    
    static func displayNoMatchesView(hostViewController: UIViewController) {
    
        let noMatchesView = UIView()
        let screenBounds = UIScreen.main.bounds
        let widthOfView = CGFloat(100)
        noMatchesView.frame = CGRect(x: (screenBounds.width / 2) - (widthOfView / 2), y: (widthOfView / 2), width: widthOfView, height: widthOfView)
        noMatchesView.backgroundColor = UIColor.clear
        noMatchesView.tag = 1
        
        let label = UILabel()
        label.frame = CGRect(x: 0, y: (widthOfView / 2) - 10, width: widthOfView, height: 20)
        label.text = "No matches yet"
        label.textColor = UIColor.darkGray
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.adjustsFontSizeToFitWidth = true
        
        noMatchesView.addSubview(label)
        hostViewController.view.addSubview(noMatchesView)
    }
    
    static func removeNoMatchesView(hostViewController: UIViewController) {
        if let viewWithTag = hostViewController.view.viewWithTag(1) {
            viewWithTag.removeFromSuperview()
        }
    }
    
    static func setUpTabAndNavBar(hostViewController: UIViewController) {
        let pinkColor = UIColor(red: 216/255, green: 27/255, blue: 96/255, alpha:1.0)
        hostViewController.navigationController?.navigationBar.tintColor = pinkColor
        hostViewController.tabBarController?.tabBar.tintColor = pinkColor
    }
}

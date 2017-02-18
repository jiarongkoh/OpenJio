//
//  NewSearchViewController.swift
//  OpenJio
//
//  Created by Koh Jia Rong on 5/2/17.
//  Copyright © 2017 Koh Jia Rong. All rights reserved.
//

import UIKit
import Eureka
import FirebaseAuth
import FirebaseDatabase
import CoreLocation

class NewSearchViewController: FormViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var ref: FIRDatabaseReference!
    var locationCoordinate: CLLocationCoordinate2D!
    var parsedUserInfo: [String: String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        self.navigationItem.title = "Search"
        DisplayUI.setUpTabAndNavBar(hostViewController: self)

        form +++
            Section()
            
            <<< PushRow<String>() {
                $0.tag = "searchActivity"
                $0.title = "Looking for..."
                $0.options = ["🍴", "🏃", "🎬"]
                $0.value = "🎬"
        }

    }

    @IBAction func doneButtonDidTap(_ sender: Any) {
        
        let valuesDictionary = form.values()
        let searchActivity = valuesDictionary["searchActivity"]
        
        if Reachability.connectedToNetwork() {
            
            if let user = FIRAuth.auth()?.currentUser {
                FIRHelperClient.sharedInstance.getUserInfoFromFIR(ref, user.uid, { (results, error) in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        //                    print(results)
                        var userInfo = results as? [String: AnyObject]
                        userInfo?[FIRConstants.Search.SearchActivities] = searchActivity as AnyObject?
                        userInfo?[FIRConstants.Search.ActivityLat] = self.locationCoordinate.latitude as AnyObject?
                        userInfo?[FIRConstants.Search.ActivityLon] = self.locationCoordinate.longitude as AnyObject?
                        
                        print("POST Activities to FIR: \(userInfo)")
                        self.ref.child("activities").child(user.uid).setValue(userInfo)
                        
                        DispatchQueue.main.async {
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                })
            }
        } else {
            DisplayUI.displayErrorMessage(Messages.NoInternetConnection, hostViewController: self, activityIndicator: nil)
        }
    }

    @IBAction func cancelButtonDidTap(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}

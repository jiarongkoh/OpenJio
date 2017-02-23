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
                }.onPresent({ (form, selectorController) in
                    selectorController.enableDeselection = false
                })
        
            <<< PushRow<String>() {
                $0.tag = "activityLocation"
                $0.title = "Coordinates"
                $0.options = ["Singapore Zoo", "Changi Airport", "USS Sentosa"]
                $0.value = "Singapore Zoo"
                }.onPresent({ (form, selectorController) in
                    selectorController.enableDeselection = false
                })


    }

    @IBAction func doneButtonDidTap(_ sender: Any) {
        
        let valuesDictionary = form.values()
        let searchActivity = valuesDictionary["searchActivity"]
        let activityLocation = valuesDictionary["activityLocation"] as? String
        
        if Reachability.connectedToNetwork() {
            
            if let user = FIRAuth.auth()?.currentUser {
                FIRHelperClient.sharedInstance.getUserInfoFromFIR(ref, user.uid, { (results, error) in
                    if let error = error {
                        print(error.localizedDescription)
                        DisplayUI.displayErrorMessage(Messages.NetworkError, hostViewController: self, activityIndicator: nil, refreshControl: nil)

                    } else {
                        var userInfo = results as? [String: AnyObject]
                        userInfo?[FIRConstants.Search.SearchActivities] = searchActivity as AnyObject?
                        
                        if activityLocation == "Singapore Zoo" {
                            userInfo?[FIRConstants.Search.ActivityLat] = 1.404584 as AnyObject?
                            userInfo?[FIRConstants.Search.ActivityLon] = 103.793077 as AnyObject?
                        } else if activityLocation == "Changi Airport" {
                            userInfo?[FIRConstants.Search.ActivityLat] = 1.368058 as AnyObject?
                            userInfo?[FIRConstants.Search.ActivityLon] = 103.991235 as AnyObject?
                        } else if activityLocation == "USS Sentosa" {
                            userInfo?[FIRConstants.Search.ActivityLat] = 1.254578 as AnyObject?
                            userInfo?[FIRConstants.Search.ActivityLon] = 103.823903 as AnyObject?
                        }
                        
                        print("POST Activities to FIR: \(userInfo)")
                        self.ref.child("activities").child(user.uid).setValue(userInfo)
                        
                        DispatchQueue.main.async {
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                })
            }
        } else {
            DisplayUI.displayErrorMessage(Messages.NoInternetConnection, hostViewController: self, activityIndicator: nil, refreshControl: nil)
        }
    }

    @IBAction func cancelButtonDidTap(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}

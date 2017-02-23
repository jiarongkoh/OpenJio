//
//  ActivityViewController.swift
//  OpenJio
//
//  Created by Koh Jia Rong on 10/2/17.
//  Copyright © 2017 Koh Jia Rong. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import MapKit

class ActivityViewController: UIViewController {

    @IBOutlet weak var letsGoButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var mapView: MKMapView!
    
    var ref: FIRDatabaseReference!
    var userUID: String? = nil
    var coordinate: CLLocationCoordinate2D!
    var parsedDictionary: [String: AnyObject]?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        DisplayUI.setUpTabAndNavBar(hostViewController: self)

        setUpButton()
        ref = FIRDatabase.database().reference()
        
        if let user = FIRAuth.auth()?.currentUser {
            userUID = user.uid
        }
        
        if Reachability.connectedToNetwork() {
            FIRHelperClient.sharedInstance.getActivityDetails(coordinate, ref) { (results, error) in
                if let error = error {
                    print(error.localizedDescription)
                    DisplayUI.displayErrorMessage(Messages.NetworkError, hostViewController: self, activityIndicator: nil, refreshControl: nil)
                } else {
                    self.parsedDictionary = results
                    
                    let matchList = results?[FIRConstants.Search.Matches] as? [String: AnyObject]
                    
                    let name = results?[FIRConstants.UserInfo.Name] as! String
                    let activity = results?[FIRConstants.Search.SearchActivities] as! String
                    let retrievedUserUID = results?[FIRConstants.UserInfo.UserUID] as! String
                    
                    if retrievedUserUID == self.userUID {
                        DispatchQueue.main.async {
                            self.setUpMapView(self.coordinate)
                            self.textView.text = "You are looking for a \(activity) buddy!"
                            self.textView.font = UIFont.boldSystemFont(ofSize: 20.0)
                            self.letsGoButton.isEnabled = false
                            self.letsGoButton.isUserInteractionEnabled = false
                            self.letsGoButton.backgroundColor = UIColor.lightGray
                        }
                        
                    } else {
                        DispatchQueue.main.async {
                            self.textView.text = "\(name) is looking for a \(activity) buddy!"
                            self.textView.font = UIFont.boldSystemFont(ofSize: 20.0)
                            self.letsGoButton.isUserInteractionEnabled = true
                            
                            self.setUpMapView(self.coordinate)
                            
                            if let _ = matchList?[self.userUID!] {
                                self.letsGoButton.alpha = 0.8
                                self.letsGoButton.isEnabled = false
                                self.letsGoButton.isUserInteractionEnabled = false
                                self.letsGoButton.backgroundColor = UIColor.lightGray
                            }
                        }
                        
                    }
                    
                }
            }

        } else {
             DisplayUI.displayErrorMessage(Messages.NoInternetConnection, hostViewController: self, activityIndicator: nil, refreshControl: nil)
        }
    }
    
    
    func setUpMapView(_ coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegionMake(coordinate, span)
        mapView.setRegion(region, animated: false)
        
        mapView.isUserInteractionEnabled = false

    }
    
    func setUpButton() {
        let buttonHeight = letsGoButton.frame.height
        letsGoButton.layer.cornerRadius = buttonHeight / 2
        letsGoButton.setTitle("Let's Go!", for: .normal)
        letsGoButton.setTitle("You've responded!", for: .disabled)
        letsGoButton.titleLabel?.adjustsFontSizeToFitWidth = true
        letsGoButton.isUserInteractionEnabled = true
    }

    @IBAction func letsGoButtonDidTap(_ sender: Any) {
        let childNode = parsedDictionary?[FIRConstants.UserInfo.UserUID] as! String
        let matchUpdate = [userUID!: false as AnyObject] as [String: AnyObject]
        
        let updateInfo = [FIRConstants.Search.Matches: matchUpdate as AnyObject] as [String : AnyObject]
        
        if Reachability.connectedToNetwork() {
            self.ref.child("activities").child(childNode).updateChildValues(updateInfo)
            dismiss(animated: true, completion: nil)
        } else {
            DisplayUI.displayErrorMessage(Messages.NoInternetConnection, hostViewController: self, activityIndicator: nil, refreshControl: nil)
        }
    }
    
    @IBAction func cancelButtonDidTap(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

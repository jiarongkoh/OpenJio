//
//  FIRHelperClient.swift
//  OpenJio
//
//  Created by Koh Jia Rong on 5/2/17.
//  Copyright © 2017 Koh Jia Rong. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import CoreLocation

class FIRHelperClient: NSObject {
    static let sharedInstance = FIRHelperClient()
        
    override init() {
        super.init()
    }
    
    func getUserInfoFromFIR(_ ref: FIRDatabaseReference, _ userUID: String, _ completionHandlerForUserInfo: @escaping (_ results: AnyObject?, _ error: NSError?) -> Void) {
        
        ref.child("users").child(userUID).observe(.value, with: { (snapshot) in
            let snapValues = snapshot.value as! [String: AnyObject]
            
            guard let userName = snapValues[FIRConstants.UserInfo.Name] as? String else {
                print("No userName from FIR Snapshots")
                return
            }
            
            guard let userGender = snapValues[FIRConstants.UserInfo.Gender] as? String else {
                print("No userGender from FIR Snapshots")
                return
            }
            
            guard let userUID = snapValues[FIRConstants.UserInfo.UserUID] as? String else {
                print("No userUID from FIR Snapshots")
                return
            }
            
            let userInfoFromFIR = [FIRConstants.UserInfo.Name: userName,
                                   FIRConstants.UserInfo.Gender: userGender,
                                   FIRConstants.UserInfo.UserUID: userUID]
            
            completionHandlerForUserInfo(userInfoFromFIR as AnyObject, nil)
            
        }) { (error) in
            print(error.localizedDescription)
            completionHandlerForUserInfo(nil, error as NSError)
        }
    }
    
    func getLocationsForActivities(_ ref: FIRDatabaseReference, _ completionHandlerForLocationsActivities: @escaping (_ results: [ActivityPin]?, _ error: NSError?) -> Void) {
        
        ref.child("activities").queryOrdered(byChild: "gender").queryEqual(toValue: "male").observe(.value, with: { (snapshot) in
            let snapValues = snapshot.value as! [String: AnyObject]
            var pinArray = [ActivityPin]()
            for snap in snapValues {
                let pin = ActivityPin(dict: snap.value as! [String : AnyObject])
                pinArray.append(pin)
            }
            
            completionHandlerForLocationsActivities(pinArray, nil)
            
        }, withCancel: { (error) in
            print(error.localizedDescription)
            completionHandlerForLocationsActivities(nil, error as NSError)

        })
    }
    
}

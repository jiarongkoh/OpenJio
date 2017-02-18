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
    
    func getLocationsForActivities(_ userCoordinate: CLLocationCoordinate2D, _ genderSearch: String, _ distanceSearch: Int, _ ref: FIRDatabaseReference, _ completionHandlerForLocationsActivities: @escaping (_ results: [ActivityPin]?, _ error: NSError?) -> Void) {
        
        var gender: String?
        let usersCoordinate = CLLocation(latitude: userCoordinate.latitude, longitude: userCoordinate.longitude)
        
        if genderSearch == "Men" {
            gender = "male"
        } else {
            gender = "female"
        }
        
        ref.child("activities").queryOrdered(byChild: "gender").queryEqual(toValue: gender!).observe(.value, with: { (snapshot) in
            let snapValues = snapshot.value as! [String: AnyObject]
            var pinArray = [ActivityPin]()
            
            for snap in snapValues {
//                print("Snap: \(snap)")
                let broadcastersCoordinate = CLLocation(latitude: snap.value[FIRConstants.Search.ActivityLat] as! Double, longitude: snap.value[FIRConstants.Search.ActivityLon] as! Double)
                
                let distance = usersCoordinate.distance(from: broadcastersCoordinate)
//                print(distance)
                
                if distance <= Double(distanceSearch * 1000) {
//                    print(snap)
                    
                    let pin = ActivityPin(dict: snap.value as! [String : AnyObject])
                    pinArray.append(pin)
                }
            }
            
            completionHandlerForLocationsActivities(pinArray, nil)
            
        }, withCancel: { (error) in
            print(error.localizedDescription)
            completionHandlerForLocationsActivities(nil, error as NSError)

        })
    }
    
    func getActivityDetails(_ coordinate: CLLocationCoordinate2D, _ ref: FIRDatabaseReference, _ completionHandlerforActivityDetails: @escaping (_ detailsArray: [String: AnyObject]?, _ error: NSError?) -> Void) {
        
        let searchLat = coordinate.latitude
        let searchLon = coordinate.longitude
        
        ref.child("activities").queryOrdered(byChild: "activity_lat").queryEqual(toValue: searchLat).observe(.value, with: { (snapshot) in
            
            let snapDictionary = snapshot.value as? [String: AnyObject]
            
            /*TO DO: MODIFY DATABASE FOR UID*/
            let firstKey = Array(snapDictionary!.keys)[0]
            
            var activityValuesDict = snapDictionary?[firstKey] as? [String: AnyObject]
            activityValuesDict?[FIRConstants.UserInfo.UserUID] = firstKey as AnyObject?
//            print(activityValuesDict)
            
            completionHandlerforActivityDetails(activityValuesDict, nil)

        
        }) { (error) in
            print(error.localizedDescription)
            completionHandlerforActivityDetails(nil, error as NSError)

        }
    }
    
    func getMatchedList(_ userUID: String, _ ref: FIRDatabaseReference, _ completionHandlerForMatchedList: @escaping (_ matchedList: [String: Bool]?, _ _error: NSError?) -> Void) {
        
        ref.child("activities").observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot.childSnapshot(forPath: userUID))
            
            let snapValue = snapshot.childSnapshot(forPath: userUID).value as! [String: AnyObject]
            guard let matchList = snapValue["matches"] as? [String: Bool] else {
                print("No matches found")
                
                let userInfo = [NSLocalizedDescriptionKey : "No Matches Found Yet"]
                completionHandlerForMatchedList(nil, NSError(domain: "error", code: 1, userInfo: userInfo))
                return
            }
            
            //            var matchedList: [String: Bool]
            
            for item in matchList {
                if item.value {
                    //                    print(item)
                }
            }
            
            completionHandlerForMatchedList(matchList, nil)
            

        }) { (error) in
            print(error.localizedDescription)
            completionHandlerForMatchedList(nil, error as NSError)

        }

    }
    
}

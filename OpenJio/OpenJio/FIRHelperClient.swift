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
                let broadcastersCoordinate = CLLocation(latitude: snap.value[FIRConstants.Search.ActivityLat] as! Double, longitude: snap.value[FIRConstants.Search.ActivityLon] as! Double)
                
                let distance = usersCoordinate.distance(from: broadcastersCoordinate)
                
                if distance <= Double(distanceSearch * 1000) {
                    
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
            
            completionHandlerforActivityDetails(activityValuesDict, nil)

        
        }) { (error) in
            print(error.localizedDescription)
            completionHandlerforActivityDetails(nil, error as NSError)

        }
    }
    
    func getMatchedList(_ userUID: String, _ ref: FIRDatabaseReference, _ completionHandlerForMatchedList: @escaping (_ matchedList: [String: Bool]?, _ error: NSError?) -> Void) {
        
        ref.child("activities").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let snapValue = snapshot.childSnapshot(forPath: userUID).value as? [String: AnyObject] {
                guard let matchList = snapValue["matches"] as? [String: Bool] else {
                    print("No match list found")
                    let userInfo = [NSLocalizedDescriptionKey : "No match list found yet"]
                    completionHandlerForMatchedList(nil, NSError(domain: "error", code: 1, userInfo: userInfo))
                    return
                }
                
                for snap in snapshot.children {
                    let snapDataSnapshot = snap as! FIRDataSnapshot
                    let snapValues = snapDataSnapshot.value as? [String: AnyObject]
                    
                    if let _ = snapValues?["matches"] as? [String: Bool] {
                    }
                }

                print("getMatchedList: \(matchList)")
                completionHandlerForMatchedList(matchList, nil)
                
            } else {
                let userInfo = [NSLocalizedDescriptionKey : "Have never dropped activity before"]
                completionHandlerForMatchedList(nil, NSError(domain: "error", code: 1, userInfo: userInfo))
            }
            
        }) { (error) in
            print(error.localizedDescription)
            completionHandlerForMatchedList(nil, error as NSError)

        }

    }
    
    func getMatchedListAsResponders(_ userUID: String, _ ref: FIRDatabaseReference, _ completionHandlerForGetListAsResponders: @escaping (_ matchedList: [String: Bool]?, _ error: NSError?) -> Void) {
        
        ref.child("users").child(userUID).observe(.value, with: { (snapshot) in
            if snapshot.hasChild("matches") {
                let snapValues = snapshot.value as? [String: AnyObject]
                guard let matchList = snapValues?["matches"] as? [String: Bool] else {
                    print("No match list found in UsersArray")
                    let userInfo = [NSLocalizedDescriptionKey : "No match list found yet"]
                    completionHandlerForGetListAsResponders(nil, NSError(domain: "error", code: 1, userInfo: userInfo))
                    return
                }
                print("GetMatchedListAsResponders: \(matchList)")
                completionHandlerForGetListAsResponders(matchList, nil)
                
            } else {
                let userInfo = [NSLocalizedDescriptionKey : "No Curated Match List"]
                completionHandlerForGetListAsResponders(nil, NSError(domain: "Error", code: 3, userInfo: userInfo))
            }
        }, withCancel: { (error) in
            print(error.localizedDescription)
            completionHandlerForGetListAsResponders(nil, error as NSError)
            

        })
    }
    
    
    func getNamesFromUserUID( _ userUID: String, _ ref: FIRDatabaseReference, _ completionHandlerForGetNamesFromUID: @escaping (_ name: String?, _ error: NSError?) -> Void) {
        
        ref.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild(userUID) {
                ref.child("users").child(userUID).observeSingleEvent(of: .value, with: { (snapshot) in
                    let snapValue = snapshot.value as! [String: AnyObject]
                    
                    guard let name = snapValue["name"] as? String else {
                        let userInfo = [NSLocalizedDescriptionKey : "No name"]
                        completionHandlerForGetNamesFromUID(nil, NSError(domain: "error", code: 2, userInfo: userInfo))

                        return
                    }
                    
                    completionHandlerForGetNamesFromUID(name, nil)
                    
                }, withCancel: { (error) in
                    print(error.localizedDescription)
                    completionHandlerForGetNamesFromUID(nil, error as NSError)
                })
            } else {
                let userInfo = [NSLocalizedDescriptionKey : "No name"]
                print("Noname")
                completionHandlerForGetNamesFromUID(nil, NSError(domain: "error", code: 2, userInfo: userInfo))

            }
            
        }) { (error) in
            print(error.localizedDescription)
            completionHandlerForGetNamesFromUID(nil, error as NSError)
        }
    }
    
}

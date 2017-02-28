//
//  FBLoginHelper.swift
//  OpenJio
//
//  Created by Koh Jia Rong on 5/2/17.
//  Copyright © 2017 Koh Jia Rong. All rights reserved.
//

import Foundation
import FBSDKLoginKit

class FBLoginHelper: NSObject {
    static let sharedInstance = FBLoginHelper()
    
    override init() {
        super.init()
    }
    
    func getUsersFacebookInfo(_ completionHandlerForGetUsersInfo: @escaping (_ results: AnyObject?, _ error: NSError?) -> Void) {
        print("GETTING USER INFO FROM FACEBOOK...")

        let parameters = ["fields": "name, first_name, last_name, gender, picture.type(large), email"]
        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: parameters)
        let connection = FBSDKGraphRequestConnection()
        connection.add(graphRequest) { (connection, results, error) in
            if let error = error {
                print(error.localizedDescription)
                completionHandlerForGetUsersInfo(nil, error as NSError?)
            }
            
            guard let userFBInfo = results as? [String: AnyObject] else {
                print("Cannot cast")
                return
            }
            
            guard let userName = userFBInfo[FBConstants.UserInfo.Name] as? String else {
                print("No userName found in FB Profile")
                return
            }
            
            guard let userFirstName = userFBInfo[FBConstants.UserInfo.FirstName] as? String else {
                print("No userFirstName found in FB Profile")
                return
            }
            
            guard let userLastName = userFBInfo[FBConstants.UserInfo.LastName] as? String else {
                print("No userLastName found in FB Profile")
                return
            }
            
            guard let userGender = userFBInfo[FBConstants.UserInfo.Gender] as? String else {
                print("No userGender found in FB Profile")
                return
            }
            
            guard let userPicture = userFBInfo[FBConstants.UserInfo.Picture] as? [String: AnyObject] else {
                print("No userPicture found in FB Profile")
                return
            }
            
            guard let userPictureData = userPicture[FBConstants.UserInfo.PictureData] as? [String: AnyObject] else {
                print("No userPictureData found in FB Profile")
                return
            }
            
            guard let userPictureURL = userPictureData[FBConstants.UserInfo.PictureURL] as? String else {
                print("No userPictureURL found in FB Profile")
                return
            }
            
            let userInfoArray = [FIRConstants.UserInfo.Name: userName,
                                 FIRConstants.UserInfo.FirstName: userFirstName,
                                 FIRConstants.UserInfo.LastName: userLastName,
                                 FIRConstants.UserInfo.Gender: userGender,
                                 FIRConstants.UserInfo.PictureURL: userPictureURL]
            completionHandlerForGetUsersInfo(userInfoArray as AnyObject?, nil)

        }
        
        connection.start()

    }
    
    func getUsersProfilePic(_ completionHandlerForProfilePic: @escaping (_ results: Data?, _ error: NSError?) -> Void) {
        print("GETTING PROFILE PIC FROM FACEBOOK...")
        
        let parameters = ["fields": "picture.type(large)"]
        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: parameters)
        let connection = FBSDKGraphRequestConnection()
        connection.add(graphRequest) { (connection, results, error) in
            if let error = error {
                print(error.localizedDescription)
                completionHandlerForProfilePic(nil, error as NSError?)
            }
            
            guard let userFBInfo = results as? [String: AnyObject] else {
                print("Cannot cast")
                return
            }
            
            guard let userPicture = userFBInfo[FBConstants.UserInfo.Picture] as? [String: AnyObject] else {
                print("No userPicture found in FB Profile")
                return
            }
            
            guard let userPictureData = userPicture[FBConstants.UserInfo.PictureData] as? [String: AnyObject] else {
                print("No userPictureData found in FB Profile")
                return
            }
            
            guard let userPictureURLString = userPictureData[FBConstants.UserInfo.PictureURL] as? String else {
                print("No userPictureURL found in FB Profile")
                return
            }
            
            let userPictureURL = URL(string: userPictureURLString)
            let imageData = try? Data(contentsOf: userPictureURL!)
            completionHandlerForProfilePic(imageData, nil)
            
        }
        
        connection.start()
        
    }
    
}

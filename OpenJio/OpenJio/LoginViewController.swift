//
//  LoginViewController.swift
//  OpenJio
//
//  Created by Koh Jia Rong on 5/2/17.
//  Copyright © 2017 Koh Jia Rong. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FBSDKLoginKit
import CoreData

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {

    @IBOutlet weak var FBLoginButton: FBSDKLoginButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var ref: FIRDatabaseReference!
    var user: User!
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.isHidden = true

        FBLoginButton.delegate = self
        FBLoginButton.readPermissions = ["email","public_profile"]
        
        ref = FIRDatabase.database().reference()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let _ = FIRAuth.auth()?.currentUser {
            self.completeLogin()

            DispatchQueue.main.async {
                self.FBLoginButton.isHidden = true
                self.activityIndicator.startAnimating()
                self.activityIndicator.isHidden = false
            }
        }
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        DispatchQueue.main.async {
            self.FBLoginButton.isHidden = true
            self.activityIndicator.startAnimating()
            self.activityIndicator.isHidden = false
        }

        if let error = error {
            print(error.localizedDescription)
        } else {
            let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            
            FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    print("User logged in: \(user)")
                    
                   FBLoginHelper.sharedInstance.getUsersFacebookInfo({ (results, error) in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        
                        if let userFBInfo = results {
                            self.addUsersToFirebase((user?.uid)!, userFBInfo)
                            self.saveToCoreData((user?.uid)!, userFBInfo)
                            self.completeLogin()

                        }
                    }
                   })
                }
            })
        }
    }
    
    func addUsersToFirebase(_ userUID: String, _ FBUserInfo: AnyObject) {
        ref.child("users").observe(.value, with: { (snapshot) in
            if !snapshot.hasChild(userUID) {
                var userInfoFromGet = FBUserInfo as! [String: String]
                userInfoFromGet[FIRConstants.UserInfo.UserUID] = userUID
                self.ref.child("users").child(userUID).setValue(userInfoFromGet)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func saveToCoreData(_ userUID: String, _ FBUserInfo: AnyObject) {
        let stack = delegate.stack
        let userName = FBUserInfo[FBConstants.UserInfo.Name] as! String
        user = User(userName: userName, userUID: userUID, context: (stack?.context)!)
        
        DispatchQueue.main.async {
            do {
                try stack?.saveContext()
                print("User Saved!")
            } catch {
                print("Error while saving.")
            }
        }

    }

    
    func completeLogin() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
        }
        performSegue(withIdentifier: "ToMainView", sender: nil)
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Log out!")
    }

}


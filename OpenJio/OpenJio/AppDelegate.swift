//
//  AppDelegate.swift
//  OpenJio
//
//  Created by Koh Jia Rong on 5/2/17.
//  Copyright © 2017 Koh Jia Rong. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let stack = CoreDataStack(modelName: "Model")

    func checkIfFirstLaunch() {
        if let firstTimeLaunch = UserDefaults.standard.value(forKey: UserDefaultsConstants.SearchPref.FirstTimeLaunch) {
            print("App launched before")
            
            if let searchPrefGender = UserDefaults.standard.value(forKey: UserDefaultsConstants.SearchPref.Gender), let searchPrefDistance = UserDefaults.standard.value(forKey: UserDefaultsConstants.SearchPref.Distance) {
                print("App launched before: \(searchPrefGender) \(searchPrefDistance)")
            }
            
        } else {
            //App has never been launched before
            print("App has never been launched before")
            
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
            
            do {
                try FIRAuth.auth()!.signOut()
            } catch let signOutError as NSError {
                print("Error signing out: \(signOutError)")
            }

            UserDefaults.standard.set(true, forKey: UserDefaultsConstants.SearchPref.FirstTimeLaunch)
            UserDefaults.standard.set("Men", forKey: UserDefaultsConstants.SearchPref.Gender)
            UserDefaults.standard.set(10, forKey: UserDefaultsConstants.SearchPref.Distance)
            UserDefaults.standard.synchronize()
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FIRApp.configure()
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        checkIfFirstLaunch()
        stack?.autoSave(60)

        return true
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        do {
            try stack?.saveContext()
        } catch {
            print("Error while saving.")
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        do {
            try stack?.saveContext()
        } catch {
            print("Error while saving.")
        }
    }
}


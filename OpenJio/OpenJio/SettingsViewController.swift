//
//  SettingsViewController.swift
//  OpenJio
//
//  Created by Koh Jia Rong on 5/2/17.
//  Copyright © 2017 Koh Jia Rong. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth
import Eureka
import CoreData

class SettingsViewController: FormViewController {

    var searchPrefGender: String?
    var searchPrefDistance: Int?
    
    var user: User!
    var profilePhoto: Photo!
    
    lazy var context: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.stack!.context
    }()
    
    lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchedRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        fetchedRequest.sortDescriptors = []
//        fetchedRequest.predicate = NSPredicate(format: "pins == %@", argumentArray: [self.pin])
        return NSFetchedResultsController(fetchRequest: fetchedRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: nil)
    }()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func fetchProfilePhotoFromCoreData() {
        do {
            try fetchedResultsController.performFetch()
            
        } catch let error as NSError {
            print("Unable to perform fetch: \(error.localizedDescription)")
        }
        
        let fetchedObjects = fetchedResultsController.fetchedObjects
        if fetchedObjects?.count != 0 {
            print("IMAGE PRESENT IN COREDATA")
            print("Number of fetchedObjects: \(fetchedObjects?.count)")
            
            self.profilePhoto = fetchedObjects?.last as! Photo
            
        }

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        user = retrieveUserCoreData()
        fetchProfilePhotoFromCoreData()
        
        searchPrefGender = UserDefaults.standard.value(forKey: "searchPrefGender") as! String?
        searchPrefDistance = UserDefaults.standard.value(forKey: "searchPrefDistance") as! Int?
        
        print("View did load: \(searchPrefGender) \(searchPrefDistance)")

        form +++
            Section(){ section in
                section.header = {
                    var header = HeaderFooterView<UIView>(.callback({
                        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
                        let imageView = UIImageView(frame: CGRect(x: 10, y: 20, width: 60, height: 60))
                        imageView.backgroundColor = .clear
                        imageView.layer.cornerRadius = imageView.frame.size.width / 2
                        imageView.clipsToBounds = true
                        
                        if self.profilePhoto != nil {
                            print("ProfilePhoto not nil")
                            DispatchQueue.main.async {
                                imageView.image = UIImage(data: self.profilePhoto.imageData as! Data)
                            }
                        } else {
                            print("ProfilePhoto nil")

                            FBLoginHelper.sharedInstance.getUsersProfilePic { (imageData, error) in
                                if let error = error {
                                    print(error.localizedDescription)
                                } else {
                                    if let imageData = imageData {
                                        let picture = Photo(user: self.user, imageData: imageData, context: self.context)
                                        self.profilePhoto = picture
                                    }
                                    
                                    do {
                                        try self.context.save()
                                    } catch let error as NSError {
                                        print("Error saving context: \(error.localizedDescription)")
                                    }
                                    
                                    DispatchQueue.main.async {
                                        imageView.image = UIImage(data: imageData!)
                                    }
                                }
                            }

                        }
                        
                        let screenSize = UIScreen().bounds.width
                        let nameLabel = UILabel(frame: CGRect(x: 100, y: 40, width: 150, height: 20))
                        nameLabel.text = self.user.userName
                        nameLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
                        
                        view.addSubview(imageView)
                        view.addSubview(nameLabel)
                        view.backgroundColor = .white
                        return view
                    }))
                    header.height = { 100 }
                    return header
                }()
        }
        
            +++ Section("Search Preference")
            <<< PushRow<String>() {
                $0.tag = "GenderPreference"
                $0.title = "Gender"
                $0.options = ["Men", "Women"]
                $0.value = searchPrefGender
            }.cellUpdate({ (cell, row) in
                let formDict = self.form.values()
                UserDefaults.standard.set(formDict["GenderPreference"], forKey: "searchPrefGender")
                UserDefaults.standard.synchronize()
                })

            <<< SliderRow() {
                $0.tag = "SearchDistance"
                $0.title = "Search Distance (km)"
                $0.value = Float(searchPrefDistance!)
                $0.minimumValue = 5.0
                $0.maximumValue = 50.0
                $0.steps = UInt(5)
            }.onChange({ (row) in
                let formDict = self.form.values()
                UserDefaults.standard.set(formDict["SearchDistance"], forKey: "searchPrefDistance")
                UserDefaults.standard.synchronize()
                })

            
            +++ Section()
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "Logout"
                }.cellSetup({ (cell, row) in
                    cell.tintColor = UIColor.red
                })
                .onCellSelection { [weak self] (cell, row) in
                    self?.displayLogoutMessage()
        }
        
    }
    
    func retrieveUserCoreData() -> User {
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        
        do {
            let results = try context.fetch(fr)
            print(results)
            let userArrays = results as? [User]
            user = userArrays?[0]
        
            print(userArrays)
        } catch let error as NSError {
            print(error)
        }

        return user

    }
    
    func loadPhoto() {
        FBLoginHelper.sharedInstance.getUsersProfilePic { (imageData, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if let imageData = imageData {
                    let picture = Photo(user: self.user, imageData: imageData, context: self.context)
                    self.profilePhoto = picture
                }
            }
        }
    }
    
    func displayLogoutMessage() {
        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let logoutAction = UIAlertAction(title: "Logout", style: .destructive) { (action) in
            self.logout()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertVC.addAction(logoutAction)
        alertVC.addAction(cancelAction)
        present(alertVC, animated: true, completion: nil)
        
           }
    
    func logout() {
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        
        do {
            try FIRAuth.auth()!.signOut()
            let controller = storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
            present(controller, animated: true, completion: nil)
            
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError)")
        }
    }
}

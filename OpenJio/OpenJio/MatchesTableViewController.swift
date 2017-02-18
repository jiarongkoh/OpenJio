//
//  MatchesTableViewController.swift
//  OpenJio
//
//  Created by Koh Jia Rong on 12/2/17.
//  Copyright © 2017 Koh Jia Rong. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FBSDKLoginKit

class MatchesTableViewController: UITableViewController {

    var ref: FIRDatabaseReference!
    var userUID: String?
    var matchedList: [String: Bool] = [:]
    var interestedNamesArray = [String]()
    var successfulMatchesArray = [String]()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureDatabase()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = FIRDatabase.database().reference()
        
        setUpTableView()
        
        if let user = FIRAuth.auth()?.currentUser {
            userUID = user.uid
        }
    }

    func configureDatabase() {
        FIRHelperClient.sharedInstance.getMatchedList(userUID!, ref) { (results, error) in
            if let error = error {
                print(error.localizedDescription)
                if error.code == 1 {
                    DispatchQueue.main.async {
                        self.navigationItem.title = "Matches"
                        DisplayUI.displayNoMatchesView(hostViewController: self)
                    }
                }
            } else {
                DisplayUI.removeNoMatchesView(hostViewController: self)
//                print(results)
                
                self.interestedNamesArray = []
                self.successfulMatchesArray = []
                for result in results! {
                    if result.value == true {
                        self.successfulMatchesArray.append(result.key)
                    } else {
                        self.interestedNamesArray.append(result.key)
                    }
                }
                
                DispatchQueue.main.async {
                    self.navigationItem.title = "Matches"
                    self.tableView.reloadData()
                }
            }
        }
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Successful matches!"
        } else {
            return "Responded to you!"
        }
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return successfulMatchesArray.count
        } else {
            return interestedNamesArray.count
        }

    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MatchesTableViewCell
        
        if indexPath.section == 0 {
            let successMatch = successfulMatchesArray[indexPath.row]
            cell.textLabel?.text = successMatch
            return cell
        } else {
            let match = interestedNamesArray[indexPath.row]
            cell.textLabel?.text = match
            return cell
        }
    }
//    
//    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
//        switch indexPath.section {
//        case 0:
//            return indexPath
//        case 1:
//            return nil
//        default:
//            return nil
//        }
//    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            let matchedName = successfulMatchesArray[indexPath.row]
            performSegue(withIdentifier: "SuccessMatch", sender: matchedName)
            
        case 1:
            let interestedName = interestedNamesArray[indexPath.row]
            performSegue(withIdentifier: "InterestedMatch", sender: interestedName)
            
        default:
            break
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SuccessMatch" {
            let destVC = segue.destination as! SuccessMatchViewController
            destVC.matchedName = sender as? String
        } else if segue.identifier == "InterestedMatch" {
            let destVC = segue.destination as! InterestedMatchViewController
            destVC.interestedName = sender as? String
        }
    }

    func setUpTableView() {
        self.navigationItem.title = "Updating..."

        self.tableView = UITableView(frame: self.tableView.frame, style: .grouped)
        self.tableView.register(MatchesTableViewCell.self, forCellReuseIdentifier: "cell")
    }

}

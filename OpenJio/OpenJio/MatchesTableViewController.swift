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
    let activityIndicator = UIActivityIndicatorView()
    
    let titleLabel: UILabel = {
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.text = "Matches"
        return titleLabel
    }()
    
    lazy var refresh: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(fetchMatches), for: .valueChanged)
        refresh.tag = 2
        return refresh
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTableView()
        configureDatabase()
        self.tableView.addSubview(refresh)
        
    }
    
    
    func configureDatabase() {
        ref = FIRDatabase.database().reference()
        
        if let user = FIRAuth.auth()?.currentUser {
            userUID = user.uid
        }
        
        fetchMatches()

    }
    
    func fetchMatches() {
        if Reachability.connectedToNetwork() {
            FIRHelperClient.sharedInstance.getMatchedList(userUID!, ref) { (results, error) in
                if let error = error {
                    print(error.localizedDescription)
                    if error.code == 1 {
                        DispatchQueue.main.async {
                            self.activityIndicator.stopAnimating()
                            self.navigationItem.titleView = self.titleLabel
                            DisplayUI.displayNoMatchesView(hostViewController: self)
                            self.refresh.endRefreshing()
                            
                        }
                    }
                } else {
                    DisplayUI.removeNoMatchesView(hostViewController: self)
                    //                print(results)
                    
                    self.interestedNamesArray = []
                    self.successfulMatchesArray = []
                    for result in results! {
                        if result.value == true {
                            
                            FIRHelperClient.sharedInstance.getNamesFromUserUID(result.key, self.ref, { (name, error) in
                                if let error = error {
                                    if error.code == 2 {
                                        DisplayUI.displayErrorMessage(Messages.NoNamesFound, hostViewController: self, activityIndicator: self.activityIndicator, refreshControl: self.refresh)
                                        
                                    }
                                } else {
                                    if let name = name {
                                        self.successfulMatchesArray.append(name)
                                        
                                        DispatchQueue.main.async {
                                            self.activityIndicator.stopAnimating()
                                            self.navigationItem.titleView = self.titleLabel
                                            self.tableView.reloadData()
                                            self.refresh.endRefreshing()
                                            self.refresh.isHidden = true

                                        }
                                        
                                    }
                                }
                                
                            })
                            
                        } else {
                            FIRHelperClient.sharedInstance.getNamesFromUserUID(result.key, self.ref, { (name, error) in
                                if let error = error {
                                    if error.code == 2 {
                                        DispatchQueue.main.async {
                                            DisplayUI.displayErrorMessage(Messages.NoNamesFound, hostViewController: self, activityIndicator: self.activityIndicator, refreshControl: self.refresh)
                                            
                                        }
                                    }
                                } else {
                                    if let name = name {
                                        self.interestedNamesArray.append(name)
                                        
                                        DispatchQueue.main.async {
                                            self.activityIndicator.stopAnimating()
                                            self.navigationItem.titleView = self.titleLabel
                                            self.tableView.reloadData()
                                            self.refresh.endRefreshing()
                                            self.refresh.isHidden = true
                                        }
                                        
                                    }
                                }
                                
                            })
                            
                        }
                    }
                    
                }
            }

        } else {

            DisplayUI.displayErrorMessage(Messages.NoInternetConnection, hostViewController: self, activityIndicator: self.activityIndicator, refreshControl: self.refresh)
            DispatchQueue.main.async {
                self.navigationItem.titleView = self.titleLabel
            }
           
        }
        
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
         if section == 0 {
            
            if successfulMatchesArray.count == 0 {
                return ""
            } else {
                return "Successful matches!"
            }
        } else {
            if interestedNamesArray.count == 0 {
                return ""
            } else {
                return "Responded to you!"
            }

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
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor(red: 216/255, green: 27/255, blue: 96/255, alpha:1.0)
        self.navigationItem.titleView =  activityIndicator

        self.tableView = UITableView(frame: self.tableView.frame, style: .grouped)
        self.tableView.register(MatchesTableViewCell.self, forCellReuseIdentifier: "cell")
        
//        let nib = UINib(nibName: "SegmentedControlTableViewCell", bundle: nil)
//        self.tableView.register(nib, forCellReuseIdentifier: "SegmentedControlTableViewCell")
        
    }

}

//
//  MatchViewController.swift
//  OpenJio
//
//  Created by Koh Jia Rong on 22/2/17.
//  Copyright © 2017 Koh Jia Rong. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FBSDKLoginKit

//FUTURE IMPLEMENTATION
class MatchViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
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
        let refresh = UIRefreshControl(frame: CGRect(x: 50, y: 100, width: 20, height: 20))
        refresh.addTarget(self, action: #selector(fetchMatches), for: .valueChanged)
        return refresh
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        
        ref = FIRDatabase.database().reference()
        
        if let user = FIRAuth.auth()?.currentUser {
            userUID = user.uid
        }

        fetchMatches(segmentedControl.selectedSegmentIndex)
    }
    
    @IBAction func segmentedControl(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            fetchMatches(0)
        case 1:
            fetchMatches(1)
        default:
            break
        }
    }
    
    func fetchMatches(_ segmentedControllerSelectedIndex: Int) {
        
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
            self.activityIndicator.hidesWhenStopped = true
            self.navigationItem.titleView = self.activityIndicator
        }
        
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
                    
                    if segmentedControllerSelectedIndex == 0 {
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
                                    }
                                    
                                }
                            }
                            
                        })

                    } else if segmentedControllerSelectedIndex == 1 {
                        FIRHelperClient.sharedInstance.getNamesFromUserUID(result.key, self.ref, { (name, error) in
                            if let error = error {
                                if error.code == 2 {
                                    DisplayUI.displayErrorMessage(Messages.NoNamesFound, hostViewController: self, activityIndicator: self.activityIndicator, refreshControl: self.refresh)
                                }
                            } else {
                                if let name = name {
                                    self.interestedNamesArray.append(name)
                                    
                                    DispatchQueue.main.async {
                                        self.activityIndicator.stopAnimating()
                                        self.navigationItem.titleView = self.titleLabel
                                        self.tableView.reloadData()
                                        self.refresh.endRefreshing()
                                    }
                                    
                                }
                            }
                            
                        })
                    }
                    
                    
                    
                    
                    
//                    if result.value == true {
//                        
//                        FIRHelperClient.sharedInstance.getNamesFromUserUID(result.key, self.ref, { (name, error) in
//                            if let error = error {
//                                if error.code == 2 {
//                                    DispatchQueue.main.async {
//                                        DisplayUI.displayErrorMessage(Messages.NoNamesFound, hostViewController: self, activityIndicator: self.activityIndicator)
//                                        self.refresh.endRefreshing()
//                                        
//                                    }
//                                    
//                                }
//                            } else {
//                                if let name = name {
//                                    self.successfulMatchesArray.append(name)
//                                    
//                                    DispatchQueue.main.async {
//                                        self.activityIndicator.stopAnimating()
//                                        self.navigationItem.titleView = self.titleLabel
//                                        self.tableView.reloadData()
//                                        self.refresh.endRefreshing()
//                                    }
//                                    
//                                }
//                            }
//                            
//                        })
//                        
//                    } else {
//                        FIRHelperClient.sharedInstance.getNamesFromUserUID(result.key, self.ref, { (name, error) in
//                            if let error = error {
//                                if error.code == 2 {
//                                    DispatchQueue.main.async {
//                                        DisplayUI.displayErrorMessage(Messages.NoNamesFound, hostViewController: self, activityIndicator: self.activityIndicator)
//                                        self.refresh.endRefreshing()
//                                        
//                                    }
//                                }
//                            } else {
//                                if let name = name {
//                                    self.interestedNamesArray.append(name)
//                                    
//                                    DispatchQueue.main.async {
//                                        self.activityIndicator.stopAnimating()
//                                        self.navigationItem.titleView = self.titleLabel
//                                        self.tableView.reloadData()
//                                        self.refresh.endRefreshing()
//                                    }
//                                    
//                                }
//                            }
//                            
//                        })
//                        
//                    }
                }
                
            }
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentedControl.selectedSegmentIndex == 0 {
            return successfulMatchesArray.count
        } else if segmentedControl.selectedSegmentIndex == 1 {
            return interestedNamesArray.count
        } else {
            return 0
        }
    }
 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MatchTableViewCell
        
        if segmentedControl.selectedSegmentIndex == 0 {
            let successMatch = successfulMatchesArray[indexPath.row]
            cell.textLabel?.text = successMatch
            return cell
        } else if segmentedControl.selectedSegmentIndex == 1 {
            let match = interestedNamesArray[indexPath.row]
            cell.textLabel?.text = match
            return cell
        } else {
            return cell
        }

    }
    
    func setUpUI() {
        view.backgroundColor = UIColor.groupTableViewBackground
        tableView.dataSource = self
        tableView.register(MatchTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.contentInset = UIEdgeInsetsMake(-36, 0, 0, 0)
        
        let pinkColor = UIColor(red: 216/255, green: 27/255, blue: 96/255, alpha:1.0)
        segmentedControl.tintColor = pinkColor
        segmentedControl.selectedSegmentIndex = 0
        
        tableView.addSubview(refresh)
    }
}

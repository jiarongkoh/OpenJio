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

class MatchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    var ref: FIRDatabaseReference!
    var userUID: String?
    var matchedList: [String: Bool] = [:]
    var interestedNamesArray = [String]()
    var successfulMatchesArray = [String]()
    var interestedUserUIDArray = [String]()
    var successfulUserUIDArray = [String]()

    let activityIndicator = UIActivityIndicatorView()
    
    let titleLabel: UILabel = {
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.text = "Matches"
        return titleLabel
    }()
    
    lazy var refresh: UIRefreshControl = {
        let refresh = UIRefreshControl(frame: CGRect(x: 50, y: 100, width: 20, height: 20))
        refresh.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return refresh
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        
        ref = FIRDatabase.database().reference()
        
        if let user = FIRAuth.auth()?.currentUser {
            userUID = user.uid
        }
        
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
            self.activityIndicator.hidesWhenStopped = true
            self.navigationItem.titleView = self.activityIndicator
        }
        
        fetchMatches(segmentedControl.selectedSegmentIndex)

        tableView.reloadData()
    }
    
    @IBAction func segmentedControl(_ sender: Any) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
        if segmentedControl.selectedSegmentIndex == 0 {
            if successfulMatchesArray.count == 0 {
                DispatchQueue.main.async {
                    self.activityIndicator.startAnimating()
                    self.activityIndicator.hidesWhenStopped = true
                    self.navigationItem.titleView = self.activityIndicator
                }
                
                refreshData()
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            
            
            }
        } else if segmentedControl.selectedSegmentIndex == 1 {
            if interestedNamesArray.count == 0 {
                DispatchQueue.main.async {
                    self.activityIndicator.startAnimating()
                    self.activityIndicator.hidesWhenStopped = true
                    self.navigationItem.titleView = self.activityIndicator
                }
                refreshData()
            }

        }
        
    }
    
    func refreshData() {
        fetchMatches(segmentedControl.selectedSegmentIndex)
    }
    
    func fetchMatches(_ segmentedControllerSelectedIndex: Int) {
        
        switch segmentedControllerSelectedIndex {
        case 0:
            
            successfulUserUIDArray = []
            successfulMatchesArray = []
            
            FIRHelperClient.sharedInstance.getMatchedListAsResponders(userUID!, ref) { (results, error) in
                if let error = error {
                    print(error.localizedDescription)
                    if error.code == 1 || error.code == 3 {
                        DispatchQueue.main.async {
                            self.activityIndicator.stopAnimating()
                            self.navigationItem.titleView = self.titleLabel
                            DisplayUI.displayNoMatchesView(hostViewController: self)
                            self.refresh.endRefreshing()
                        }
                    }
                } else {
                    if let results = results {
                        
                        for result in results {
                            FIRHelperClient.sharedInstance.getNamesFromUserUID(result.key, self.ref, { (name, error) in
                                if let error = error {
                                    if error.code == 2 {
                                        DisplayUI.displayErrorMessage(Messages.NoNamesFound, hostViewController: self, activityIndicator: self.activityIndicator, refreshControl: self.refresh)
                                        DispatchQueue.main.async {
                                            self.refresh.endRefreshing()
                                        }
                                    }
                                } else {
                                    if let name = name {
                                        self.successfulMatchesArray.append(name)
                                        self.successfulUserUIDArray.append(result.key)
                                        
                                        FIRHelperClient.sharedInstance.getMatchedList(self.userUID!, self.ref, { (results, error) in
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
                                                
                                                for result in results! {
                                                    
                                                    if result.value {
                                                        FIRHelperClient.sharedInstance.getNamesFromUserUID(result.key, self.ref, { (name, error) in
                                                            if let error = error {
                                                                if error.code == 2 {
                                                                    DisplayUI.displayErrorMessage(Messages.NoNamesFound, hostViewController: self, activityIndicator: self.activityIndicator, refreshControl: self.refresh)
                                                                    DispatchQueue.main.async {
                                                                        self.refresh.endRefreshing()
                                                                    }
                                                                }
                                                            } else {
                                                                if let name = name {
                                                                    self.successfulMatchesArray.append(name)
                                                                    self.successfulUserUIDArray.append(result.key)
                                                                    
                                                                    DispatchQueue.main.async {
                                                                        self.activityIndicator.stopAnimating()
                                                                        self.navigationItem.titleView = self.titleLabel
                                                                        self.tableView.reloadData()
                                                                        self.refresh.endRefreshing()
                                                                    }
                                                                }
                                                                
                                                                print("Successful matches : \(self.successfulMatchesArray)")
                                                                
                                                            }
                                                        })
                                                    } else {
                                                        DispatchQueue.main.async {
                                                            self.activityIndicator.stopAnimating()
                                                            self.navigationItem.titleView = self.titleLabel
                                                            self.tableView.reloadData()
                                                            self.refresh.endRefreshing()
                                                        }
                                                    }
                                                }
                                            }
                                        })
                                    }
                                }
                            })
                        }
                    }
                }
            }

        case 1:
            
            self.interestedUserUIDArray = []
            self.interestedNamesArray = []
            

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
                    
                    for result in results! {
                        
                        if result.value == false {
                            FIRHelperClient.sharedInstance.getNamesFromUserUID(result.key, self.ref, { (name, error) in
                                if let error = error {
                                    if error.code == 2 {
                                        DisplayUI.displayErrorMessage(Messages.NoNamesFound, hostViewController: self, activityIndicator: self.activityIndicator, refreshControl: self.refresh)
                                        DispatchQueue.main.async {
                                            self.refresh.endRefreshing()
                                        }
                                    }
                                } else {
                                    if let name = name {
                                        self.interestedNamesArray.append(name)
                                        self.interestedUserUIDArray.append(result.key)
                                        DispatchQueue.main.async {
                                            self.activityIndicator.stopAnimating()
                                            self.navigationItem.titleView = self.titleLabel
                                            self.tableView.reloadData()
                                            self.refresh.endRefreshing()
                                        }
                                        
                                    }
                                    print("Interested :\(self.interestedNamesArray)")

                                }
                            })
                            
                        } else {
                            DispatchQueue.main.async {
                                self.activityIndicator.stopAnimating()
                                self.navigationItem.titleView = self.titleLabel
                                self.tableView.reloadData()
                                self.refresh.endRefreshing()
                            }
                        }
                    }
                }
            }
            
        default:
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.navigationItem.titleView = self.titleLabel
                self.tableView.reloadData()
                self.refresh.endRefreshing()
            }
            break
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch segmentedControl.selectedSegmentIndex {
        case 0:
            let successName = successfulMatchesArray[indexPath.row]
            let successUserUID = successfulUserUIDArray[indexPath.row]
            performSegue(withIdentifier: "SuccessMatch", sender: [successName, successUserUID])
            
        case 1:
            let interestedName = interestedNamesArray[indexPath.row]
            let interestedUserUID = interestedUserUIDArray[indexPath.row]
            performSegue(withIdentifier: "InterestedMatch", sender: [interestedName, interestedUserUID])
            
        default:
            break
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SuccessMatch" {
            let destVC = segue.destination as! SuccessMatchViewController
            let sentInfo = sender as! [AnyObject]
            destVC.matchedName = sentInfo[0] as? String
            
        } else if segue.identifier == "InterestedMatch" {
            let destVC = segue.destination as! InterestedMatchViewController
            let sentInfo = sender as! [AnyObject]
            destVC.interestedName = sentInfo[0] as? String
            destVC.interestedUserUID = sentInfo[1] as? String
        }
    }
    
    func setUpUI() {
        view.backgroundColor = UIColor.groupTableViewBackground
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MatchTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.contentInset = UIEdgeInsetsMake(-36, 0, 0, 0)
        
        let pinkColor = UIColor(red: 216/255, green: 27/255, blue: 96/255, alpha:1.0)
        segmentedControl.tintColor = pinkColor
        segmentedControl.selectedSegmentIndex = 0
        
        activityIndicator.color = pinkColor
        
        let refreshView = UIView(frame: CGRect(x: 0, y: 20, width: 0, height: 0))
        tableView.addSubview(refreshView)
        refreshView.addSubview(refresh)
    }
}

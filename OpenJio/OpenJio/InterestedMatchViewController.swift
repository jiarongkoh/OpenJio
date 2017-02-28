//
//  InterestedMatchViewController.swift
//  OpenJio
//
//  Created by Koh Jia Rong on 18/2/17.
//  Copyright © 2017 Koh Jia Rong. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class InterestedMatchViewController: UIViewController {

    @IBOutlet weak var interestedNameLabel: UILabel!
    @IBOutlet weak var respondButton: UIButton!
    
    var ref: FIRDatabaseReference!
    var interestedName: String?
    var interestedUserUID: String?
    var userUID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpButton()
        configureDatabase()
        DisplayUI.setUpTabAndNavBar(hostViewController: self)

        if let interestedName = interestedName {
            interestedNameLabel.text = "\(interestedName) wanna go with you!"
            interestedNameLabel.adjustsFontSizeToFitWidth = true
        }
    
    }
    
    func configureDatabase() {
        ref = FIRDatabase.database().reference()
        
        if let user = FIRAuth.auth()?.currentUser {
            userUID = user.uid
        }
    }
    
    func setUpButton() {
        let buttonHeight = respondButton.frame.height
        respondButton.layer.cornerRadius = buttonHeight / 2
        respondButton.setTitle("Alright let's go!", for: .normal)
        respondButton.setTitle("Ok it's a go!", for: .disabled)
        respondButton.titleLabel?.adjustsFontSizeToFitWidth = true
        respondButton.isUserInteractionEnabled = true
    }
    
    @IBAction func respondButtonDidTap(_ sender: Any) {
        
        let response = [interestedUserUID!: true] as [String: Bool]
        ref.child("activities").child(userUID!).child("matches").updateChildValues(response)
        
        let interestedUserResponse = [userUID!: true] as [String: Bool]
        ref.child("users").child(interestedUserUID!).child("matches").updateChildValues(interestedUserResponse)
        
        DispatchQueue.main.async {
            self.respondButton.isUserInteractionEnabled = false
            self.respondButton.backgroundColor = UIColor.lightGray
        }
    }
    


}

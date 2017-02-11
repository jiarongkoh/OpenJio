//
//  ActivityViewController.swift
//  OpenJio
//
//  Created by Koh Jia Rong on 10/2/17.
//  Copyright © 2017 Koh Jia Rong. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ActivityViewController: UIViewController {

    @IBOutlet weak var letsGoButton: UIButton!
    
    var ref: FIRDatabaseReference!
    var userUID: String? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        ref = FIRDatabase.database().reference()
        
        if let user = FIRAuth.auth()?.currentUser {
            userUID = user.uid
        }

    }

    @IBAction func letsGoButtonDidTap(_ sender: Any) {
       
        let postInfo = [FIRConstants.Search.ActivityLat: 1.432795006039413 as AnyObject,
                        FIRConstants.Search.ActivityLon: 103.83464196024194 as AnyObject,
                        FIRConstants.UserInfo.Gender: "male",
                        FIRConstants.UserInfo.Name: "Andrew",
                        FIRConstants.Search.SearchActivities: "🍴",
                        FIRConstants.Search.Matches: [userUID, "asdfhaisnudaisu"]] as [String : Any]
        
        
        self.ref.child("activities").child("person2").setValue(postInfo)

    }
}

//
//  SuccessMatchViewController.swift
//  OpenJio
//
//  Created by Koh Jia Rong on 18/2/17.
//  Copyright © 2017 Koh Jia Rong. All rights reserved.
//

import UIKit

class SuccessMatchViewController: UIViewController {

    @IBOutlet weak var matchedNameLabel: UILabel!
    
    var matchedName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DisplayUI.setUpTabAndNavBar(hostViewController: self)

        if let matchedName = matchedName {
            matchedNameLabel.text = "Alright! It's a go with \(matchedName)!"
            matchedNameLabel.adjustsFontSizeToFitWidth = true
        }
    
    }


}

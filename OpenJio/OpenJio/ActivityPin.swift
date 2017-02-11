//
//  ActivityPin.swift
//  OpenJio
//
//  Created by Koh Jia Rong on 5/2/17.
//  Copyright © 2017 Koh Jia Rong. All rights reserved.
//

import Foundation

struct ActivityPin {
    let name: String?
    let lat: Double?
    let lon: Double?
    let gender: String?
    let searchActivities: String?
    
    init(dict: [String:AnyObject]) {
        name = dict[FIRConstants.UserInfo.Name] as! String?
        lat = dict[FIRConstants.Search.ActivityLat] as! Double?
        lon = dict[FIRConstants.Search.ActivityLon] as! Double?
        gender = dict[FIRConstants.UserInfo.Gender] as! String?
        searchActivities = dict[FIRConstants.Search.SearchActivities] as! String?
    }
}

//
//  User+CoreDataClass.swift
//  
//
//  Created by Koh Jia Rong on 11/2/17.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData

//@objc(User)
public class User: NSManagedObject {

    convenience init(userName: String, userUID: String, context: NSManagedObjectContext) {
        
        if let ent = NSEntityDescription.entity(forEntityName: "User", in: context) {
            self.init(entity: ent, insertInto: context)
            self.userName = userName
            self.userUID = userUID
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
}

//
//  User+CoreDataProperties.swift
//  
//
//  Created by Koh Jia Rong on 11/2/17.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User");
    }

    @NSManaged public var userName: String?
    @NSManaged public var userUID: String?
    @NSManaged public var photo: Photo?

}

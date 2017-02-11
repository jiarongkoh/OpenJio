//
//  Photo+CoreDataProperties.swift
//  
//
//  Created by Koh Jia Rong on 11/2/17.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo");
    }

    @NSManaged public var imageData: NSData?
    @NSManaged public var user: User?

}

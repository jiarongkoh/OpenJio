//
//  Photo+CoreDataClass.swift
//  
//
//  Created by Koh Jia Rong on 11/2/17.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData

//@objc(Photo)
public class Photo: NSManagedObject {

    convenience init(user: User, imageData: Data, context: NSManagedObjectContext) {
        
        if let ent = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
            self.init(entity: ent, insertInto: context)
            self.imageData = imageData as NSData
            self.user = user

        } else {
            fatalError("Unable to find Entity name!")
        }
    }

}

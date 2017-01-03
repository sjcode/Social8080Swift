//
//  BlockThread+CoreDataProperties.swift
//  
//
//  Created by sujian on 2016/12/30.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension BlockThread {

    @NSManaged var tid: String?
    @NSManaged var uid: String?

}

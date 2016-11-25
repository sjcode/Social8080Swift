//
//  RecentReadThread+CoreDataProperties.swift
//  
//
//  Created by sujian on 11/9/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension RecentReadThread {

    @NSManaged var tid: String?
    @NSManaged var uid: String?
    @NSManaged var title: String?
    @NSManaged var datetime: String?
    @NSManaged var author: String?
    @NSManaged var link: String?
    @NSManaged var owner: String?
}

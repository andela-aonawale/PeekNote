//
//  Reminder.swift
//  PeekNote
//
//  Created by Ahmed Onawale on 3/20/16.
//  Copyright © 2016 Ahmed Onawale. All rights reserved.
//

import Foundation
import CoreData

class Reminder: NSManagedObject {
    @NSManaged var date: NSDate
    @NSManaged var repeats: Bool
    
    convenience init(date: NSDate, repeats: Bool, insertIntoManagedObjectContext context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Reminder", inManagedObjectContext: context)!
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        self.date = date
        self.repeats = repeats
    }
}
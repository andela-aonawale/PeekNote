//
//  Reminder.swift
//  PeekNote
//
//  Created by Ahmed Onawale on 3/20/16.
//  Copyright © 2016 Ahmed Onawale. All rights reserved.
//

import Foundation
import CoreData
import UIKit

final class Reminder: NSManagedObject {
    
    @NSManaged var date: NSDate
    @NSManaged var repeats: Repeat
    @NSManaged var note: Note?
    
    convenience init(date: NSDate, repeats: Repeat, insertIntoManagedObjectContext context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Reminder", inManagedObjectContext: context)!
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        self.date = date
        self.repeats = repeats
        self.scheduleNotification()
    }
    
    func scheduleNotification() {
        UILocalNotification.scheduleNotificationForReminder(self)
    }
    
    override func prepareForDeletion() {
        super.prepareForDeletion()
        UILocalNotification.cancelNotificationForReminder(self)
    }
    
}
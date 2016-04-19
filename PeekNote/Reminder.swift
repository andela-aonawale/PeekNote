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
    @NSManaged var note: Note
    @NSManaged var place: Place?
    
    convenience init(date: NSDate, note: Note, repeats: Repeat, insertIntoManagedObjectContext context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName(Reminder.entityName(), inManagedObjectContext: context)!
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        self.date = date
        self.note = note
        self.repeats = repeats
    }
    
    func scheduleNotification() {
        UILocalNotification.scheduleNotificationForReminder(self)
    }
    
    func unScheduleNotification() {
        UILocalNotification.cancelNotificationForReminder(self)
    }
    
    override func prepareForDeletion() {
        super.prepareForDeletion()
        unScheduleNotification()
    }
    
}
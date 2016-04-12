//
//  Extension.swift
//  PeekNote
//
//  Created by Ahmed Onawale on 3/20/16.
//  Copyright © 2016 Ahmed Onawale. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreLocation

let showNetworkActivityIndicator = { visible in
    UIApplication.sharedApplication().networkActivityIndicatorVisible = visible
}

extension UITableView {
    
    func reloadSection(index: Int) {
        reloadSections(NSIndexSet(index: index), withRowAnimation: .Automatic)
    }
    
}

extension NSManagedObjectContext {
    
    func saveChanges() {
        do {
            try save()
        } catch {
            rollback()
        }
    }
    
    func fetchEntity(entity: NSManagedObject.Type, matchingPredicate predicate: NSPredicate?, sortBy: [String: Bool]?) -> [NSManagedObject]? {
        let fetchRequest = NSFetchRequest(entityName: entity.entityName())
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortBy?.map { NSSortDescriptor(key: $0, ascending: $1)}
        do {
            return try executeFetchRequest(fetchRequest) as? [NSManagedObject]
        } catch {
            return nil
        }
    }
    
    func deleteAllEntity(entity: NSManagedObject.Type, matchingPredicate predicate: NSPredicate?) {
        let fetchRequest = NSFetchRequest(entityName: entity.entityName())
        fetchRequest.predicate = predicate
        fetchRequest.includesPropertyValues = false
        let managedObjects = fetchEntity(entity, matchingPredicate: predicate, sortBy: nil)
        managedObjects?.forEach { deleteObject($0) }
    }
    
}

extension NSManagedObject {
    class func entityName() -> String {
        let fullClassName = NSStringFromClass(object_getClass(self))
        let nameComponents = fullClassName.characters.split { $0 == "." }.map {String($0)}
        return nameComponents.last!
    }
}

extension UILocalNotification {
    
    static func cancelNotificationForReminder(reminder: Reminder) {
        let objectID = reminder.objectID.URIRepresentation().absoluteString
        guard let notification = UILocalNotification.notificationWithID(objectID) else { return }
        UIApplication.sharedApplication().cancelLocalNotification(notification)
    }
    
    static func notificationWithID(objectID: String) -> UILocalNotification? {
        guard let notifications = UIApplication.sharedApplication().scheduledLocalNotifications else {
            return nil
        }
        for notification in notifications {
            guard let id = notification.userInfo?["objectID"] as? String else { break }
            guard objectID == id else { continue }
            return notification
        }
        return nil
    }
    
    static func scheduleNotificationForReminder(reminder: Reminder) {
        let objectID = reminder.objectID.URIRepresentation().absoluteString
        if let notification = UILocalNotification.notificationWithID(objectID) {
            UIApplication.sharedApplication().cancelLocalNotification(notification)
        }
        let notification = UILocalNotification()
        if let place = reminder.place {
            let coordinate = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
            let region = CLCircularRegion(center: coordinate, radius: 100, identifier: place.id)
            region.notifyOnEntry = place.trigger == .OnEntry
            region.notifyOnExit = place.trigger == .OnExit
            notification.region = region
            notification.regionTriggersOnce = false
        } else {
            notification.fireDate = reminder.date
            notification.timeZone = .defaultTimeZone()
            notification.repeatInterval = reminder.repeats.calendarUnit()
        }
        notification.alertBody = reminder.note?.title
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.userInfo = ["objectID": objectID]
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
}

extension Int {
    func incrementBy(value: Int) -> Int {
        return self + value
    }
}

extension NSDate {
    
    static var dateFormatter: RelativeDateFormatter {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: RelativeDateFormatter?
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = RelativeDateFormatter()
        }
        return Static.instance!
    }
    
    var prettified: String {
        return NSDate.dateFormatter.stringForDate(self)
    }
    
    class var nextHourDate: NSDate {
        let calendar = NSCalendar.currentCalendar()
        let currentHour = calendar.component(.Hour, fromDate: NSDate())
        let nextHourValue = currentHour.incrementBy(1)
        let value = nextHourValue > 23 ? 0 : nextHourValue
        return calendar.dateBySettingUnit(.Hour, value: value, ofDate: NSDate(), options: .MatchFirst)!
    }
    
}

public func ==(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedSame
}

public func <=(lhs: NSDate, rhs: NSDate) -> Bool {
    let res = lhs.compare(rhs)
    return res == .OrderedAscending || res == .OrderedSame
}

public func >=(lhs: NSDate, rhs: NSDate) -> Bool {
    let res = lhs.compare(rhs)
    return res == .OrderedDescending || res == .OrderedSame
}

public func >(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedDescending
}

public func <(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedAscending
}

extension UIColor {
    
    static func primaryColor() -> UIColor {
        return UIColor(red:0.92, green:0.76, blue:0.31, alpha:1.00)
    }
    
    static func secondaryColor() -> UIColor {
        return UIColor(red: 0.29, green: 0.31, blue: 0.33, alpha: 1.00)
    }

    static func trashColor() -> UIColor {
        return UIColor(red: 0.29, green: 0.31, blue: 0.33, alpha: 1.00)
    }
    
    static func deleteColor() -> UIColor {
        return UIColor(red:0.90, green: 0.23, blue: 0.05, alpha: 1.00)
    }
    
    static func backgroundColor() -> UIColor {
        return UIColor(patternImage: UIImage(named: "background")!)
    }
    
}

extension String {
    
    static func mediumDateShortTime(date: NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = .currentLocale()
        dateFormatter.timeStyle = .ShortStyle
        dateFormatter.dateStyle = .MediumStyle
        return dateFormatter.stringFromDate(date)
    }
    
    static func mediumDateNoTime(date: NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = .currentLocale()
        dateFormatter.timeStyle = .NoStyle
        dateFormatter.dateStyle = .MediumStyle
        return dateFormatter.stringFromDate(date)
    }
    
    static func fullDate(date: NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = .currentLocale()
        dateFormatter.timeStyle = .NoStyle
        dateFormatter.dateStyle = .FullStyle
        return dateFormatter.stringFromDate(date)
    }
}

extension UIView {
    static func viewWithImageNamed(name: String, labelName: String) -> UIView {
        let image = UIImageView(image: UIImage(named: name))
        image.contentMode = .Center
        image.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = labelName
        label.textColor = .whiteColor()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let view = UIView()
        view.addSubview(image)
        view.addSubview(label)
        
        let c1 = NSLayoutConstraint(item: label, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0)
        let c2 = NSLayoutConstraint(item: label, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1, constant: 20)
        
        let c3 = NSLayoutConstraint(item: image, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0)
        let c4 = NSLayoutConstraint(item: image, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1, constant: -10)
        
        view.addConstraints([c1, c2, c3, c4])
        return view
    }
}

extension UIViewController {
    
    var contentViewController: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.topViewController ?? self
        }
        return self
    }
    
    func dismiss() {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
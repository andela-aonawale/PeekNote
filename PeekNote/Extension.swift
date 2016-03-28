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
}

extension NSManagedObjectContext {
    func saveContext() {
        if hasChanges {
            do {
                try save()
            } catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
}

extension UIViewController {
    var contentViewController: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.topViewController ?? self
        }
        return self
    }
}

extension NSString {
    var isEmpty: Bool {
        return self.length == 0
    }
}
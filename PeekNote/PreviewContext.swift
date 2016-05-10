//
//  PreviewContext.swift
//  PeekNote
//
//  Created by Ahmed Onawale on 5/10/16.
//  Copyright © 2016 Ahmed Onawale. All rights reserved.
//

import Foundation
import CoreData
import UIKit

protocol PreviewContext: class {
    var managedObjectContext: NSManagedObjectContext! { get set }
    func tagNote(note: Note)
    func shareNote(note: Note)
    func addReminderToNote(note: Note)
    func deleteNote(note: Note)
}

extension PreviewContext where Self: UIViewController {
    func tagNote(note: Note) {
        let viewController = TagListViewController(managedObjectContext: managedObjectContext, note: note)
        presentViewControllerFormSheet(viewController, completion: nil)
    }
    
    func shareNote(note: Note) {
        guard UIDevice.currentDevice().userInterfaceIdiom == .Phone else { return }
        let activityViewController = UIActivityViewController(activityItems: [note.shareableString], applicationActivities: nil)
        presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    func addReminderToNote(note: Note) {
        let viewController = AddReminderViewController(managedObjectContext: managedObjectContext, note: note)
        presentViewControllerFormSheet(viewController) {
            let settings = UIUserNotificationSettings( forTypes: [.Alert, .Sound, .Badge], categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        }
    }
    
    func deleteNote(note: Note) {
        managedObjectContext.deleteObject(note)
        managedObjectContext.saveChanges()
    }
}
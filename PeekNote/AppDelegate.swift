//
//  AppDelegate.swift
//  PeekNote
//
//  Created by Ahmed Onawale on 3/20/16.
//  Copyright © 2016 Ahmed Onawale. All rights reserved.
//

import UIKit
import SWRevealViewController

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?
    var persistenceStack: PersistenceStack!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        persistenceStack = PersistenceStack.sharedStack()
        
        // init side menu
        let rearViewController = SideMenuViewController(style: .Plain)
        rearViewController.currentIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        rearViewController.managedObjectContext = persistenceStack.managedObjectContext
        let rearNavController = UINavigationController(rootViewController: rearViewController)
        
        // init splitview & inject managedObjectContext into note view controller
        let splitViewController = window?.rootViewController as! UISplitViewController
        let nav = splitViewController.viewControllers.first as! UINavigationController
        let notesVC = nav.topViewController as! NotesViewController
        notesVC.managedObjectContext = persistenceStack.managedObjectContext
        notesVC.fetchPredicate = NSPredicate(format: "state == \(State.Normal.rawValue)")
        
        // application wide customization
        UINavigationBar.appearance().barStyle = UIBarStyle.Black
        UINavigationBar.appearance().translucent = false
        UINavigationBar.appearance().barTintColor = UIColor(red:0.98, green:0.74, blue:0.02, alpha:1.00)
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        window?.tintColor = UIColor(red:0.98, green:0.74, blue:0.02, alpha:1.00)
        
        // set SWRevealViewController as rootviewcontroller
        let revealViewController = SWRevealViewController(rearViewController: rearNavController, frontViewController: splitViewController)
        window?.rootViewController = revealViewController
        window?.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        persistenceStack.saveContext()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        persistenceStack.saveContext()
    }

    // MARK: - Split view

    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController, ontoPrimaryViewController primaryViewController:UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? NoteDetailViewController else { return false }
        if topAsDetailController.note == nil {
            // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
            return true
        }
        return false
    }

}


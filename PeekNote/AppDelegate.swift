//
//  AppDelegate.swift
//  PeekNote
//
//  Created by Ahmed Onawale on 3/20/16.
//  Copyright © 2016 Ahmed Onawale. All rights reserved.
//

import UIKit
import TagListView
import SWRevealViewController

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {
    
    // MARK: Types
    
    enum ShortcutIdentifier: String {
        case First
        
        // MARK: Initializers
        
        init?(fullType: String) {
            guard let last = fullType.componentsSeparatedByString(".").last else { return nil }
            
            self.init(rawValue: last)
        }
        
        // MARK: Properties
        
        var type: String {
            return NSBundle.mainBundle().bundleIdentifier! + ".\(self.rawValue)"
        }
    }
    
    lazy var notesViewController: NotesViewController = {
        let revealViewController = UIApplication.sharedApplication().keyWindow?.rootViewController as! SWRevealViewController
        let splitViewController = revealViewController.frontViewController as! UISplitViewController
        let nav = splitViewController.viewControllers.first as! UINavigationController
        return nav.topViewController as! NotesViewController
    }()
    
    @available(iOS 9.0, *)
    func handleShortCutItem(shortcutItem: UIApplicationShortcutItem) -> Bool {
        var handled = false
        
        // Verify that the provided `shortcutItem`'s `type` is one handled by the application.
        guard ShortcutIdentifier(fullType: shortcutItem.type) != nil else { return false }
        
        guard let shortCutType = shortcutItem.type as String? else { return false }
        
        switch shortCutType {
        case ShortcutIdentifier.First.type:
            notesViewController.newNote(nil)
            handled = true
        default:
            break
        }
        return handled
    }

    var window: UIWindow?
    var persistenceStack: PersistenceStack!
    
    /// Saved shortcut item used as a result of an app launch, used later when app is activated.
    var launchedShortcutItem: AnyObject?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        persistenceStack = PersistenceStack.sharedStack()
        
        // init side menu
        let rearViewController = SideMenuViewController(managedObjectContext: persistenceStack.managedObjectContext)
        let rearNavController = UINavigationController(rootViewController: rearViewController)
        
        // init splitview & inject managedObjectContext into note view controller
        let splitViewController = window?.rootViewController as! UISplitViewController
        let nav = splitViewController.viewControllers.first as! UINavigationController
        let notesVC = nav.topViewController as! NotesViewController
        notesVC.managedObjectContext = persistenceStack.managedObjectContext
        notesVC.fetchPredicate = NSPredicate(format: "state == \(State.Normal.rawValue)")
        notesVC.controllerState = ControllerState.Notes(nil)
        splitViewController.delegate = self
        
        // application wide customization
        UINavigationBar.appearance().barStyle = .Black
        UINavigationBar.appearance().translucent = false
        UINavigationBar.appearance().barTintColor = .primaryColor()
        UINavigationBar.appearance().tintColor = .whiteColor()
        
        UISegmentedControl.appearance().tintColor = .primaryColor()
        
        func configureView(view: UIView.Type..., color: UIColor? = nil) {
            view.forEach {
                $0.appearance().backgroundColor = color ?? .backgroundColor()
            }
        }
        
        configureView(UITableView.self, UITableViewCell.self, TagListView.self, UIToolbar.self, UITextView.self)
        
        window?.tintColor = .primaryColor()
        
        // set SWRevealViewController as rootviewcontroller
        let revealViewController = SWRevealViewController(rearViewController: rearNavController, frontViewController: splitViewController)
        window?.rootViewController = revealViewController
        window?.makeKeyAndVisible()
        
        var shouldPerformAdditionalDelegateHandling = true
        
        // If a shortcut was launched, display its information and take the appropriate action
        if #available(iOS 9.0, *), let shortcutItem = launchOptions?[UIApplicationLaunchOptionsShortcutItemKey] as? UIApplicationShortcutItem {
            
            launchedShortcutItem = shortcutItem as UIApplicationShortcutItem
            
            // This will block "performActionForShortcutItem:completionHandler" from being called.
            shouldPerformAdditionalDelegateHandling = false
        }
        persistenceStack.cleanUpTrash()
        return shouldPerformAdditionalDelegateHandling
    }
    
    /*
     Called when the user activates your application by selecting a shortcut on the home screen, except when
     application(_:,willFinishLaunchingWithOptions:) or application(_:didFinishLaunchingWithOptions) returns `false`.
     You should handle the shortcut in those callbacks and return `false` if possible. In that case, this
     callback is used if your application is already launched in the background.
     */
    @available(iOS 9.0, *)
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        let handledShortCutItem = handleShortCutItem(shortcutItem)
        completionHandler(handledShortCutItem)
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
        guard #available(iOS 9.0, *), let shortcut = launchedShortcutItem as? UIApplicationShortcutItem else { return }
        handleShortCutItem(shortcut)
        launchedShortcutItem = nil
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


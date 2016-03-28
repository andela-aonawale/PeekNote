//
//  SideMenuViewController.swift
//  PeekNote
//
//  Created by Ahmed Onawale on 3/27/16.
//  Copyright © 2016 Ahmed Onawale. All rights reserved.
//

import UIKit
import CoreData
import SWRevealViewController

private let reuseIdentifier = "Sidebar Cell"

class SideMenuViewController: UITableViewController {

    var tags: [Tag]?
    var currentIndexPath: NSIndexPath!
    var managedObjectContext: NSManagedObjectContext!
    
    // Mark: - Fetched Request
    
    func fetchAllTags() -> [Tag]? {
        let fetchRequest = NSFetchRequest(entityName: "Tag")
        let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [nameSortDescriptor]
        return try? managedObjectContext.executeFetchRequest(fetchRequest) as! [Tag]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tags = fetchAllTags()
        editButtonItem().action = #selector(editTags(_:))
        navigationItem.leftBarButtonItem = editButtonItem()
        tableView.tableFooterView = UIView()
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
    }
    
    func editTags(sender: UIBarButtonItem) {
        if !tableView.editing {
            editButtonItem().title = "Done"
            editButtonItem().style = .Done
            revealViewController().setFrontViewPosition(.RightMost, animated: true)
        } else {
            editButtonItem().title = "Edit"
            editButtonItem().style = .Plain
            revealViewController().setFrontViewPosition(.Right, animated: true)
        }
        tableView.setEditing(!tableView.editing, animated: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        guard managedObjectContext.hasChanges else { return }
        tags = fetchAllTags()
        tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Automatic)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0, 2:
            return 2
        default:
            return tags?.count ?? 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)
        if indexPath.section == 0 && indexPath.row == 0 {
            cell.textLabel?.text = "Notes"
            cell.imageView?.image = UIImage(named: "Note")
        } else if indexPath.section == 0 && indexPath.row == 1 {
            cell.textLabel?.text = "Reminders"
            cell.imageView?.image = UIImage(named: "Alarm Clock")
        } else if indexPath.section == 2 && indexPath.row == 0 {
            cell.textLabel?.text = "Archive"
            cell.imageView?.image = UIImage(named: "Archive")
        } else if indexPath.section == 2 && indexPath.row == 1 {
            cell.textLabel?.text = "Trash"
            cell.imageView?.image = UIImage(named: "Trash")
        } else {
            cell.textLabel?.text = tags?[indexPath.row].name
            cell.imageView?.image = UIImage(named: "Tag")
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 { return "Tags"}
        return "\n"
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let revealController = revealViewController()
        var predicate: NSPredicate?
        let path = (indexPath.section, indexPath.row)
        
        switch path {
        case let (section, row) where section == currentIndexPath.section && row == currentIndexPath.row:
            revealController.setFrontViewPosition(FrontViewPosition.Left, animated: true)
            return
        case let (section, row) where section == 0 && row == 0:
            predicate = NSPredicate(format: "state == \(State.Normal.rawValue)")
        case let (section, row) where section == 0 && row == 1:
            predicate = NSPredicate(format: "reminder != nil")
        case let (section, row) where section == 1:
            predicate = NSPredicate(format: "tags contains[c] %@", tags![row])
        case let (section, row) where section == 2 && row == 0:
            predicate = NSPredicate(format: "state == \(State.Archived.rawValue)")
        case let (section, row) where section == 2 && row == 1:
            predicate = NSPredicate(format: "state == \(State.Trashed.rawValue)")
        default:
            break
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let splitViewController = storyboard.instantiateViewControllerWithIdentifier("SplitViewController") as! UISplitViewController
        let nav = splitViewController.viewControllers.first as! UINavigationController
        let notesVC = nav.topViewController as! NotesViewController
        notesVC.managedObjectContext = managedObjectContext
        notesVC.fetchPredicate = predicate
        
        revealController.pushFrontViewController(splitViewController, animated: true)
        currentIndexPath = indexPath
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.section == 1 && tableView.editing
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .Delete
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let tag = tags![indexPath.row]
        managedObjectContext.deleteObject(tag)
        tags?.removeAtIndex(indexPath.row)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }

}

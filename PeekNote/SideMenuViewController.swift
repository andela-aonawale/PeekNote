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

enum ControllerState {
    case Notes(String?)
    case Reminders(String?)
    case Archive(String?)
    case Trash(String?)
    case Tag(String?)
    
    func title() -> String {
        switch self {
        case .Notes:
            return "Notes"
        case .Reminders:
            return "Reminders"
        case .Archive:
            return "Archive"
        case .Trash:
            return "Trash"
        case .Tag:
            return "Tag"
        }
    }
}

final class SideMenuViewController: UITableViewController {

    var tags = [Tag]()
    var currentIndexPath: NSIndexPath!
    var managedObjectContext: NSManagedObjectContext!
    
    // Mark: - Fetched Request
    
    func fetchAllTags() -> [Tag] {
        return managedObjectContext.fetchEntity(Tag.self, matchingPredicate: nil, sortBy: ["name": true]) as? [Tag] ?? []
    }
    
    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
        self.currentIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        super.init(style: .Plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editButtonItem().action = #selector(editTags(_:))
        navigationItem.leftBarButtonItem = editButtonItem()
        tableView.tableFooterView = UIView()
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
    }
    
    func editTags(sender: UIBarButtonItem) {
        if tableView.editing {
            editButtonItem().title = "Edit"
            editButtonItem().style = .Plain
            revealViewController().setFrontViewPosition(.Right, animated: true)
        } else {
            editButtonItem().title = "Done"
            editButtonItem().style = .Done
            revealViewController().setFrontViewPosition(.RightMost, animated: true)
        }
        tableView.setEditing(!tableView.editing, animated: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tags = fetchAllTags()
        tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Automatic)
        editButtonItem().enabled = !tags.isEmpty
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
            return tags.count
        }
    }
    
    // MARK: - Table view delegate

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)
        if indexPath.section == 0 && indexPath.row == 0 {
            cell.textLabel?.text = ControllerState.Notes(nil).title()
            cell.imageView?.image = UIImage(named: "Note")
        } else if indexPath.section == 0 && indexPath.row == 1 {
            cell.textLabel?.text = ControllerState.Reminders(nil).title()
            cell.imageView?.image = UIImage(named: "Alarm Clock")
        } else if indexPath.section == 2 && indexPath.row == 0 {
            cell.textLabel?.text = ControllerState.Archive(nil).title()
            cell.imageView?.image = UIImage(named: "Archive")
        } else if indexPath.section == 2 && indexPath.row == 1 {
            cell.textLabel?.text = ControllerState.Trash(nil).title()
            cell.imageView?.image = UIImage(named: "Trash")
        } else {
            cell.textLabel?.text = tags[indexPath.row].name
            cell.imageView?.image = UIImage(named: "Tag")
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 && !tags.isEmpty { return "Tags" }
        if section == 1 && tags.isEmpty { return nil }
        return "\n"
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let revealController = revealViewController()
        var predicate: NSPredicate?
        let path = (indexPath.section, indexPath.row)
        var state = ControllerState.Notes(nil)
        
        switch path {
        case let (section, row) where section == currentIndexPath.section && row == currentIndexPath.row:
            revealController.setFrontViewPosition(FrontViewPosition.Left, animated: true)
            return
        case let (section, row) where section == 0 && row == 0:
            state = .Notes(nil)
            predicate = NSPredicate(format: "state == \(State.Normal.rawValue)")
        case let (section, row) where section == 0 && row == 1:
            state = .Reminders(nil)
            predicate = NSPredicate(format: "reminder != nil AND state == \(State.Normal.rawValue)")
        case let (section, row) where section == 1:
            state = .Tag(tags[row].name)
            predicate = NSPredicate(format: "tags contains[c] %@ AND state == \(State.Normal.rawValue)", tags[row])
        case let (section, row) where section == 2 && row == 0:
            state = .Archive(nil)
            predicate = NSPredicate(format: "state == \(State.Archived.rawValue)")
        case let (section, row) where section == 2 && row == 1:
            state = .Trash(nil)
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
        notesVC.controllerState = state
        switch state {
        case .Tag(let name):
            notesVC.title = name
        default:
            notesVC.title = state.title()
        }
        
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
        let tag = tags[indexPath.row]
        managedObjectContext.deleteObject(tag)
        tags.removeAtIndex(indexPath.row)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }

}

//
//  SideMenuViewController.swift
//  PeekNote
//
//  Created by Ahmed Onawale on 3/27/16.
//  Copyright © 2016 Ahmed Onawale. All rights reserved.
//

import UIKit
import CoreData

class SideMenuViewController: UITableViewController {
    
    var managedObjectContext: NSManagedObjectContext!
    
    // Mark: - Fetched Results Controller
    
    lazy var tags: [Tag]? = {
        let fetchRequest = NSFetchRequest(entityName: "Tag")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
          managedObjectContext: self.managedObjectContext,
          sectionNameKeyPath: nil,
          cacheName: nil)
        return try? self.managedObjectContext.executeFetchRequest(fetchRequest) as! [Tag]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        managedObjectContext = PersistenceStack.sharedStack().managedObjectContext
        tableView.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 2 }
        if section == 2 { return 2 }
        return tags?.count ?? 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Sidebar Cell", forIndexPath: indexPath)
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

}

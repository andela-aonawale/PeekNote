//
//  MasterViewController.swift
//  PeekNote
//
//  Created by Ahmed Onawale on 3/20/16.
//  Copyright © 2016 Ahmed Onawale. All rights reserved.
//

import UIKit
import CoreData

class NotesViewController: UITableViewController {
    
    var managedObjectContext: NSManagedObjectContext!
    var tableViewDataSource: UITableViewFRCDataSource!
    
    // Mark: - Fetched Results Controller
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Note")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "updatedDate", ascending: false)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        return fetchedResultsController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        navigationItem.rightBarButtonItem = editButtonItem()
        
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableViewDataSource = UITableViewFRCDataSource(tableView: tableView, reuseIdentifier: "Note Cell", fetchedResultsController: fetchedResultsController)
        tableViewDataSource.delegate = self
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func insertNewNote(sender: UIBarButtonItem) {
        let note = Note(title: "", body: "", insertIntoManagedObjectContext: managedObjectContext)
        performSegueWithIdentifier("showDetail", sender: note)
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        guard let identifier = segue.identifier else { return }
        switch identifier {
        case "showDetail":
            let controller = segue.destinationViewController.contentViewController as! NoteDetailViewController
            controller.managedObjectContext = managedObjectContext
            controller.note = sender as! Note
            controller.delegate = self
        default:
            break
        }
    }
}

extension NotesViewController: NoteDetailViewControllerDelegate {
    func noteDetailViewController(controller: NoteDetailViewController, didEndEditingNote note: Note) {
        if note.title.isEmpty && note.body.isEmpty {
            managedObjectContext.deleteObject(note)
        }
        managedObjectContext.saveContext()
    }
}

extension NotesViewController: UITableViewFRCDataSourceDelegate {
    func tableViewFRCDataSource(dataSource: UITableViewFRCDataSource, configureCell cell: UITableViewCell, withObject object: NSManagedObject) {
        guard let cell = cell as? NoteTableViewCell else { return }
        cell.note = object as! Note
    }
    
    func tableViewFRCDataSource(dataSource: UITableViewFRCDataSource, deleteObject object: NSManagedObject) {
        managedObjectContext.deleteObject(object)
        managedObjectContext.saveContext()
    }
}

extension NotesViewController {
    // MARK: - UITableViewDelegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let note = fetchedResultsController.objectAtIndexPath(indexPath)
        performSegueWithIdentifier("showDetail", sender: note)
    }
}

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
    var fetchedResultsControllerDataSource: FetchedResultsControllerDataSource!
    
    // Mark: - Fetched Results Controller
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Note")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        return fetchedResultsController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        self.navigationItem.rightBarButtonItem = editButtonItem()
        fetchedResultsControllerDataSource = FetchedResultsControllerDataSource(tableView: tableView, reuseIdentifier: "Note Cell", fetchedResultsController: fetchedResultsController)
        fetchedResultsControllerDataSource.delegate = self
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
        managedObjectContext.saveContext()
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        guard let identifier = segue.identifier else { return }
        switch identifier {
        case "showDetail":
            let controller = (segue.destinationViewController).contentViewController as! NoteDetailViewController
            controller.note = sender as! Note
            controller.delegate = self
        default:
            break
        }
    }
}

extension NotesViewController: NoteDetailViewControllerDelegate {
    func didEndEditingNote(note: Note) {
        if note.title.isEmpty && note.body.isEmpty {
            managedObjectContext.deleteObject(note)
        }
    }
}

extension NotesViewController: FetchedResultsControllerDataSourceDelegate {
    func configureCell(cell: UITableViewCell, withNote note: Note) {
        cell.textLabel?.text = note.title
        cell.detailTextLabel?.text = note.body
    }
    
    func deleteNote(note: Note) {
        managedObjectContext.deleteObject(note)
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

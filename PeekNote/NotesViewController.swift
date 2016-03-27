//
//  MasterViewController.swift
//  PeekNote
//
//  Created by Ahmed Onawale on 3/20/16.
//  Copyright © 2016 Ahmed Onawale. All rights reserved.
//

import UIKit
import CoreData
import PeekPop

class NotesViewController: UITableViewController {
    
    var peekPop: PeekPop?
    var peekLocation: CGPoint?
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
        
        peekPop = PeekPop(viewController: self)
        peekPop?.registerForPreviewingWithDelegate(self, sourceView: tableView)
        
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableViewDataSource = UITableViewFRCDataSource(tableView: tableView, reuseIdentifier: "Note Cell", fetchedResultsController: fetchedResultsController)
        tableViewDataSource.delegate = self
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navigationController?.setNavigationBarHidden(false, animated: true)
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

extension NotesViewController: PeekPopPreviewingDelegate {
    
    func previewingContext(previewingContext: PreviewingContext, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let vc = storyboard?.instantiateViewControllerWithIdentifier("NotePreviewViewController") as? NotePreviewViewController else {
            return nil
        }
        guard let indexPath = tableView.indexPathForRowAtPoint(location) else { return nil }
        peekLocation = location
        navigationController?.setNavigationBarHidden(true, animated: true)
        previewingContext.sourceRect = tableView.rectForRowAtIndexPath(indexPath)
        vc.note = fetchedResultsController.objectAtIndexPath(indexPath) as! Note
        return vc
    }
    
    func previewingContext(previewinshowDetailgContext: PreviewingContext, commitViewController viewControllerToCommit: UIViewController) {
        guard let location = peekLocation else { return }
        let indexPath = tableView.indexPathForRowAtPoint(location)!
        let note = fetchedResultsController.objectAtIndexPath(indexPath)
        performSegueWithIdentifier("showDetail", sender: note)
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
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath, withObject object: NSManagedObject) {
        guard let cell = cell as? NoteTableViewCell else { return }
        cell.note = object as! Note
    }
    
    func deleteObject(object: NSManagedObject) {
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

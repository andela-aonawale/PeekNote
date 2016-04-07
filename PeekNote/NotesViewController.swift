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
import SWRevealViewController

private let cacheName = "NotesCache"

final class NotesViewController: UITableViewController {
    
    var peekPop: PeekPop?
    var peekLocation: CGPoint?
    var managedObjectContext: NSManagedObjectContext!
    var tableViewDataSource: UITableViewFRCDataSource!
    
    var fetchPredicate: NSPredicate? {
        didSet {
            NSFetchedResultsController.deleteCacheWithName(cacheName)
        }
    }
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
        
    // Mark: - Fetched Results Controller
    
    lazy var fetchedResultsController: NSFetchedResultsController = { [unowned self] in
        let fetchRequest = NSFetchRequest(entityName: Note.entityName())
        fetchRequest.predicate = self.fetchPredicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: cacheName)
        return fetchedResultsController
    }()
    
    func configurePeekPop() {
        peekPop = PeekPop(viewController: self)
        peekPop?.registerForPreviewingWithDelegate(self, sourceView: tableView)
    }
    
    func configureDataSource() {
        tableViewDataSource = UITableViewFRCDataSource(tableView: tableView, reuseIdentifier: "Note Cell", fetchedResultsController: fetchedResultsController)
        tableViewDataSource.delegate = self
    }
    
    func configureTableView() {
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func configureSidebar() {
        guard let revealViewController = revealViewController() else { return }
        menuButton.target = revealViewController
        menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
        view.addGestureRecognizer(revealViewController.panGestureRecognizer())
    }
    
    func configureNavigation() {
        navigationItem.rightBarButtonItem = editButtonItem()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureDataSource()
        configureNavigation()
        configurePeekPop()
        configureTableView()
        configureSidebar()
        splitViewController?.delegate = self
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
        default:
            break
        }
    }
}

extension NotesViewController: UISplitViewControllerDelegate {
    
    // MARK: - Split view
    
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController, ontoPrimaryViewController primaryViewController:UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController,
        viewController = secondaryAsNavController.topViewController as? NoteDetailViewController else { return false }
        // Return true to indicate that we have handled the collapse by doing nothing;
        //the secondary controller will be discarded.
        return viewController.note == nil
    }
    
}

extension NotesViewController: PeekPopPreviewingDelegate {
    
    func previewingContext(previewingContext: PreviewingContext, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let vc = storyboard?.instantiateViewControllerWithIdentifier("NotePreviewViewController") as? NotePreviewViewController,
        indexPath = tableView.indexPathForRowAtPoint(location) else { return nil }
        peekLocation = location
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

extension NotesViewController: UITableViewFRCDataSourceDelegate {

    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let note = fetchedResultsController.objectAtIndexPath(indexPath) as! Note
        
        let archiveAction = UITableViewRowAction(style: .Default, title: "Archive") { _ in
            note.state = .Archived
        }
        archiveAction.backgroundColor = .trashColor()
        let unArchiveAction = UITableViewRowAction(style: .Normal, title: "Unarchive") { _ in
            note.state = .Normal
        }
        let trashAction = UITableViewRowAction(style: .Default, title: "Trash") { _ in
            note.state = .Trashed
        }
        let recoverAction = UITableViewRowAction(style: .Normal, title: "Recover") { _ in
            note.state = .Normal
        }
        let deleteAction = UITableViewRowAction(style: .Destructive, title: "Delete") { [weak self] _ in
            let alert = UIAlertController(title: nil, message: "Are you sure you want to delete this note", preferredStyle: .Alert)
            let deleteAction = UIAlertAction(title: "Delete", style: .Default) { [weak self] _ in
                self?.deleteObject(note)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alert.addAction(deleteAction)
            alert.addAction(cancelAction)
            self?.presentViewController(alert, animated: true, completion: nil)
        }
        switch note.state {
        case .Normal:
            return [trashAction, archiveAction]
        case .Archived:
            return [trashAction, unArchiveAction]
        case .Trashed:
            return [deleteAction, recoverAction]
        }
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath, withObject object: NSManagedObject) {
        guard let cell = cell as? NoteTableViewCell,
        note = object as? Note else { return }
        cell.note = note
    }
    
    func deleteObject(object: NSManagedObject) {
        managedObjectContext.deleteObject(object)
    }
    
}

extension NotesViewController {
    
    // MARK: - UITableViewDelegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let note = fetchedResultsController.objectAtIndexPath(indexPath)
        performSegueWithIdentifier("showDetail", sender: note)
    }
    
}

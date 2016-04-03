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
import MCSwipeTableViewCell

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
        let fetchRequest = NSFetchRequest(entityName: "Note")
        fetchRequest.predicate = self.fetchPredicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "updatedDate", ascending: false)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: cacheName)
        return fetchedResultsController
    }()
    
    func configurePeekPop() {
        peekPop = PeekPop(viewController: self)
//        peekPop?.registerForPreviewingWithDelegate(self, sourceView: tableView)
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

extension NotesViewController: UITableViewFRCDataSourceDelegate {
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath, withObject object: NSManagedObject) {
        guard let cell = cell as? NoteTableViewCell,
        note = object as? Note else { return }
        cell.note = note
        cell.firstTrigger = 0.4
        cell.secondTrigger = 0.6
        cell.defaultColor = UIColor.lightGrayColor()
        customizeCell(cell, forState: note.state)
    }

    typealias CellStyle = (firstView: UIView, secondView: UIView, firstColor: UIColor, secondColor: UIColor)
    
    func cellStyleForState(state: State) -> CellStyle {
        var firstView: UIView!
        var secondView: UIView!
        var firstColor: UIColor!
        var secondColor: UIColor!
        
        switch state {
        case .Normal:
            firstView = UIView.viewWithImageNamed("Archive Filled", labelName: "Archive")
            secondView = UIView.viewWithImageNamed("Trash Filled", labelName: "Trash")
            firstColor = .trashColor()
            secondColor = .deleteColor()
        case .Archived:
            firstView = UIView.viewWithImageNamed("Delete Archive Filled", labelName: "Unarchive")
            secondView = UIView.viewWithImageNamed("Trash Filled", labelName: "Trash")
            firstColor = .trashColor()
            secondColor = .deleteColor()
        case .Trashed:
            firstView = UIView.viewWithImageNamed("Recover Trash", labelName: "Recover")
            secondView = UIView.viewWithImageNamed("Delete Filled", labelName: "Delete")
            firstColor = .trashColor()
            secondColor = .deleteColor()
        }
        
        return (firstView, secondView, firstColor, secondColor)
    }
    
    func customizeCell(cell: MCSwipeTableViewCell, forState noteState: State) {
        let style = cellStyleForState(noteState)
        cell.setSwipeGestureWithView(style.firstView, color: style.firstColor, mode: .Exit, state: .State3) { [weak self] cell, state, _ in
            self?.commitCell(cell, toState: state, withNoteState: noteState)
        }
        cell.setSwipeGestureWithView(style.secondView, color: style.secondColor, mode: .Exit, state: .State4) { [weak self] cell, state, _ in
            self?.commitCell(cell, toState: state, withNoteState: noteState)
        }
    }
    
    func commitCell(cell: MCSwipeTableViewCell, toState state: MCSwipeTableViewCellState, withNoteState noteState: State) {
        guard let indexPath = tableView.indexPathForCell(cell) else { return }
        guard let note = fetchedResultsController.objectAtIndexPath(indexPath) as? Note else { return }
        
        switch noteState {
        case .Normal:
            (state == .State3) ? (note.state = .Archived) : (note.state = .Trashed)
        case .Archived:
            state == .State3 ? (note.state = .Normal) : (note.state = .Trashed)
        case .Trashed:
            state == .State3 ? (note.state = .Normal) : {
                let alert = UIAlertController(title: nil, message: "Are you sure you want to delete this note", preferredStyle: .Alert)
                let deleteAction = UIAlertAction(title: "Delete", style: .Default) { [weak self] _ in
                    self?.managedObjectContext.deleteObject(note)
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { _ in
                    cell.swipeToOriginWithCompletion(nil)
                }
                alert.addAction(deleteAction)
                alert.addAction(cancelAction)
                presentViewController(alert, animated: true, completion: nil)
            }()
        }
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

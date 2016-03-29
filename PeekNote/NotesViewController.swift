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

class NotesViewController: UITableViewController {
    
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
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
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
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let viewController = secondaryAsNavController.topViewController as? NoteDetailViewController else { return false }
        // Return true to indicate that we have handled the collapse by doing nothing;
        //the secondary controller will be discarded.
        return viewController.note == nil
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

extension NotesViewController: UITableViewFRCDataSourceDelegate {
    
    func viewWithImageNamed(name: String, labelName: String) -> UIView {
        let image = UIImageView(image: UIImage(named: name))
        image.contentMode = .Center
        image.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = labelName
        label.textColor = .whiteColor()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let view = UIView()
        view.addSubview(image)
        view.addSubview(label)
        
        let c1 = NSLayoutConstraint(item: label, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0)
        let c2 = NSLayoutConstraint(item: label, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1, constant: 20)
        
        let c3 = NSLayoutConstraint(item: image, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0)
        let c4 = NSLayoutConstraint(item: image, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1, constant: -10)
        
        view.addConstraints([c1, c2, c3, c4])
        return view
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath, withObject object: NSManagedObject) {
        guard let cell = cell as? NoteTableViewCell else { return }
        guard let note = object as? Note else { return }
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
            firstView = viewWithImageNamed("Archive Filled", labelName: "Archive")
            secondView = viewWithImageNamed("Trash Filled", labelName: "Trash")
            firstColor = UIColor(red: 0.29, green: 0.31, blue: 0.33, alpha: 1.00)
            secondColor = UIColor(red:0.90, green: 0.23, blue: 0.05, alpha: 1.00)
        case .Archived:
            firstView = viewWithImageNamed("Delete Archive Filled", labelName: "Unarchive")
            secondView = viewWithImageNamed("Trash Filled", labelName: "Trash")
            firstColor = UIColor(red: 0.29, green: 0.31, blue: 0.33, alpha: 1.00)
            secondColor = UIColor(red:0.90, green: 0.23, blue: 0.05, alpha: 1.00)
        case .Trashed:
            firstView = viewWithImageNamed("Recover Trash", labelName: "Recover")
            secondView = viewWithImageNamed("Delete Filled", labelName: "Delete")
            firstColor = UIColor(red: 0.29, green: 0.31, blue: 0.33, alpha: 1.00)
            secondColor = UIColor(red:0.90, green: 0.23, blue: 0.05, alpha: 1.00)
        }
        
        return (firstView, secondView, firstColor, secondColor)
    }
    
    func customizeCell(cell: MCSwipeTableViewCell, forState noteState: State) {
        let style = cellStyleForState(noteState)
        cell.setSwipeGestureWithView(style.firstView, color: style.firstColor, mode: .Exit, state: .State3) { cell, state, mode in
            self.commitCell(cell, toState: state, withNoteState: noteState)
        }
        cell.setSwipeGestureWithView(style.secondView, color: style.secondColor, mode: .Exit, state: .State4) { cell, state, mode in
            self.commitCell(cell, toState: state, withNoteState: noteState)
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
            state == .State3 ? (note.state = .Normal) : managedObjectContext.deleteObject(note)
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

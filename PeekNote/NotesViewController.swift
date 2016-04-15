//
//  MasterViewController.swift
//  PeekNote
//
//  Created by Ahmed Onawale on 3/20/16.
//  Copyright © 2016 Ahmed Onawale. All rights reserved.
//

import UIKit
import CoreData
import MGSwipeTableCell
import SWRevealViewController

private let cacheName = "NotesCache"

final class NotesViewController: UITableViewController {
    
    var managedObjectContext: NSManagedObjectContext!
    var tableViewDataSource: UITableViewFRCDataSource!
    var controllerState: ControllerState?
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
    }
    
    func configurePeepPop() {
        guard #available(iOS 9.0, *), traitCollection.forceTouchCapability == .Available else { return }
        registerForPreviewingWithDelegate(self, sourceView: view)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureDataSource()
        configureTableView()
        configureSidebar()
        configurePeepPop()
        configureToolbar()
        splitViewController?.delegate = self
    }

    override func viewWillAppear(animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.collapsed
        super.viewWillAppear(animated)
    }
    
    func configureToolbar() {
        guard let state = controllerState else { return }
        switch state {
        case .Archive:
            navigationController?.toolbarHidden = true
        case .Trash:
            navigationController?.toolbarHidden = false
            setToolbarItems(itemsForState(state, title: ""), animated: false)
        case .Reminders:
            navigationController?.toolbarHidden = false
            setToolbarItems(itemsForState(state, title: "Reminder"), animated: false)
        default:
            navigationController?.toolbarHidden = false
            setToolbarItems(itemsForState(state, title: "Note"), animated: false)
        }
    }
    
    func itemsForState(state: ControllerState, title: String) -> [UIBarButtonItem] {
        switch state {
        case .Trash:
            let item1 = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
            let item2 = UIBarButtonItem(title: "Empty Trash", style: .Plain, target: self, action: #selector(emptyTrash(_:)))
            item2.enabled = fetchedResultsController.fetchedObjects?.count > 0
            let item3 = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
            return [item1, item2, item3]
        default:
            let count = fetchedResultsController.fetchedObjects?.count ?? 0
            let title = count < 1 ? "No \(title)s" : count > 1 ? "\(count) \(title)s" : "\(count) \(title)"
            let item1 = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
            let item2 = UIBarButtonItem(title: title, style: .Plain, target: nil, action: nil)
            let item3 = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
            let item4 = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: #selector(newNote(_:)))
            return [item1, item2, item3, item4]
        }
    }
    
    func emptyTrash(sender: UIBarButtonItem) {
        let title = "Empty Trash"
        let message = "All notes in Trash will be permanently deleted"
        Alert.warn(self, title: title, message: message, confirmTitle: "Empty Trash", confirmAction: { [weak self] _ in
            let predicate = NSPredicate(format: "state == \(State.Trashed.rawValue)")
            self?.managedObjectContext.deleteAllEntity(Note.self, matchingPredicate: predicate)
            self?.managedObjectContext.saveChanges()
            sender.enabled = false
        }, cancelAction: nil)
    }
    
    func newNote(sender: UIBarButtonItem?) {
        guard let state = controllerState else { return }
        let note = Note(title: "", body: "", insertIntoManagedObjectContext: managedObjectContext)
        switch state {
        case .Tag(let name):
            let predicate = NSPredicate(format: "name == %@", name!)
            let tag = managedObjectContext.fetchEntity(Tag.self, matchingPredicate: predicate)?.first as! Tag
            tag.notes.insert(note)
        default: break
        }
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

extension NotesViewController: PreviewControllerDelegate {
    
    func tagNote(note: Note) {
        let viewController = TagListViewController(managedObjectContext: managedObjectContext, note: note)
        presentViewController(viewController, barButtonItem: nil, completion: nil)
    }
    
    func shareNote(note: Note) {
        let activityViewController = UIActivityViewController(activityItems: [note.shareableString], applicationActivities: nil)
        presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    func addReminderToNote(note: Note) {
        let viewController = AddReminderViewController(managedObjectContext: managedObjectContext, note: note)
        presentViewController(viewController, barButtonItem: nil) {
            let settings = UIUserNotificationSettings( forTypes: [.Alert, .Sound, .Badge], categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        }
    }
    
    func deleteNote(note: Note) {
        managedObjectContext.deleteObject(note)
        managedObjectContext.saveChanges()
    }
    
}

@available(iOS 9.0, *)
extension NotesViewController: UIViewControllerPreviewingDelegate {
    // MARK: UIViewControllerPreviewingDelegate
    
    /// Create a previewing view controller to be shown at "Peek".
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        // Obtain the index path and the cell that was pressed.
        guard let indexPath = tableView.indexPathForRowAtPoint(location),
        cell = tableView.cellForRowAtIndexPath(indexPath),
        detailViewController = storyboard?.instantiateViewControllerWithIdentifier("NoteDetailViewController") as? NoteDetailViewController,
        note = fetchedResultsController.objectAtIndexPath(indexPath) as? Note else { return nil }
        detailViewController.note = note
        detailViewController.managedObjectContext = managedObjectContext
        detailViewController.delegate = self
        
        /*
         Set the height of the preview by setting the preferred content size of the detail view controller.
         Width should be zero, because it's not used in portrait.
         */
        let minimumSize = detailViewController.view.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        detailViewController.preferredContentSize = CGSize(width: 0.0, height: minimumSize.height)
        
        // Set the source rect to the cell frame, so surrounding elements are blurred.
        previewingContext.sourceRect = cell.frame
        
        return detailViewController
    }
    
    /// Present the view controller for the "Pop" action.
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        // Reuse the "Peek" view controller for presentation.
        showViewController(viewControllerToCommit, sender: self)
        navigationController?.setToolbarHidden(true, animated: true)
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

extension NotesViewController: MGSwipeTableCellDelegate {
    // Mark: MGSwipeTableCellDelegate
    
    func setupButton(button: UIButton...) {
        button.forEach {
            let spacing: CGFloat = 5.0
            let imageSize = $0.imageView!.image!.size
            $0.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: -imageSize.width, bottom: -(imageSize.height + spacing), right: 0.0)
            let labelString = NSString(string: $0.titleLabel!.text!)
            let titleSize = labelString.sizeWithAttributes([NSFontAttributeName: $0.titleLabel!.font])
            $0.imageEdgeInsets = UIEdgeInsets(top: -(titleSize.height + spacing), left: 0.0, bottom: 0.0, right: -titleSize.width)
        }
    }
    
    func swipeTableCell(cell: MGSwipeTableCell!, swipeButtonsForDirection direction: MGSwipeDirection, swipeSettings: MGSwipeSettings!, expansionSettings: MGSwipeExpansionSettings!) -> [AnyObject]! {
        guard let state = controllerState where direction == .RightToLeft else { return nil }
        swipeSettings.transition = .Border
        expansionSettings.buttonIndex = 0
        expansionSettings.fillOnTrigger = true
        expansionSettings.threshold = 1

        let trash = MGSwipeButton(title: "Trash", icon: UIImage(named: "Trash Filled"), backgroundColor: .redColor(), padding: 5) {
            ($0 as! NoteTableViewCell).note.state = .Trashed
            return false
        }
        let archive = MGSwipeButton(title: "Archive", icon: UIImage(named: "Archive Filled"), backgroundColor: .trashColor(), padding: 5) {
            ($0 as! NoteTableViewCell).note.state = .Archived
            return false
        }
        let unarchive = MGSwipeButton(title: "Unarchive", icon: UIImage(named: "Delete Archive"), backgroundColor: .trashColor(), padding: 5) {
            ($0 as! NoteTableViewCell).note.state = .Normal
            return false
        }
        let recover = MGSwipeButton(title: "Recover", icon: UIImage(named: "Recover Trash"), backgroundColor: .trashColor(), padding: 5) {
            ($0 as! NoteTableViewCell).note.state = .Normal
            return false
        }
        let delete = MGSwipeButton(title: "Delete", icon: UIImage(named: "Delete Filled"), backgroundColor: .redColor(), padding: 5) { [unowned self] cell in
            let message = "Are you sure you want to delete this note"
            Alert.warn(self, title: nil, message: message, confirmTitle: "Delete", confirmAction: { _ in
                self.managedObjectContext.deleteObject((cell as! NoteTableViewCell).note)
            }, cancelAction: { _ in
                cell.hideSwipeAnimated(true)
            })
            return false
        }
        
        setupButton(trash, archive, unarchive, recover, delete)
        
        switch state {
        case .Archive:
            return [trash, unarchive]
        case .Trash:
            return [delete, recover]
        default:
            return [trash, archive]
        }
    }
    
}

extension NotesViewController: UITableViewFRCDataSourceDelegate {

    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath, withObject object: NSManagedObject) {
        guard let cell = cell as? NoteTableViewCell,
        note = object as? Note else { return }
        cell.note = note
        cell.delegate = self
    }
    
    func didChangeObject(anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        configureToolbar()
    }
}

extension NotesViewController {
    
    // MARK: - UITableViewDelegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let note = fetchedResultsController.objectAtIndexPath(indexPath)
        performSegueWithIdentifier("showDetail", sender: note)
    }
    
}

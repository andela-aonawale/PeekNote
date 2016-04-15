//
//  TagListViewController.swift
//  PeekNote
//
//  Created by Ahmed Onawale on 3/25/16.
//  Copyright © 2016 Ahmed Onawale. All rights reserved.
//

import UIKit
import CoreData

private let reuseIdentifier = "Tag Cell"

final class TagListViewController: UITableViewController {
    
    var note: Note
    let searchBar = UISearchBar()
    var managedObjectContext: NSManagedObjectContext
    private var tableViewDataSource: FilterableFRCDataSource!
    
    let nib = UINib(nibName: "TagCellHeader", bundle: nil)
    var headerView: TagCellHeader!
    
    // Mark: - Fetched Results Controller
    
    lazy var fetchedResultsController: NSFetchedResultsController = { [unowned self] in
        let fetchRequest = NSFetchRequest(entityName: Tag.entityName())
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        return fetchedResultsController
    }()
    
    override func dismiss() {
        searchBar.resignFirstResponder()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func addTag() {
        guard let name = searchBar.text where !name.isEmpty else { return }
        searchBar.resignFirstResponder()
        tableView.reloadData()
        _ = Tag(name: name, insertIntoManagedObjectContext: managedObjectContext)
        searchBar.text?.removeAll()
        setTableViewHeaderHidden(true)
    }
    
    func setTableViewHeaderHidden(hidden: Bool) {
        UIView.animateWithDuration(0.2) { [weak self] in
            self?.tableView.contentInset.top = hidden ? -50 : 0
        }
    }
    
    func configureTableHeader() {
        headerView = nib.instantiateWithOwner(nil, options: nil)[0] as! TagCellHeader
        let gesture = UITapGestureRecognizer(target: self, action: #selector(addTag))
        headerView.addGestureRecognizer(gesture)
        tableView.contentInset.top = -50
    }
    
    init(managedObjectContext: NSManagedObjectContext, note: Note) {
        self.managedObjectContext = managedObjectContext
        self.note = note
        super.init(style: .Plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.placeholder = "Add tag"
        navigationItem.titleView = searchBar
        
        configureTableHeader()
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.tableFooterView = UIView()
        tableView.allowsMultipleSelection = true
        
        tableViewDataSource = FilterableFRCDataSource(tableView: tableView, reuseIdentifier: reuseIdentifier, fetchedResultsController: fetchedResultsController, searchBar: searchBar)
        tableViewDataSource.delegate = self

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(dismiss))
    }

}

extension TagListViewController {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let tag = fetchedResultsController.objectAtIndexPath(indexPath) as! Tag
        note.tags.insert(tag)
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let tag = fetchedResultsController.objectAtIndexPath(indexPath) as! Tag
        note.tags.remove(tag)
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerView
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
}

extension TagListViewController: UITableViewFRCDataSourceDelegate {
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath, withObject object: NSManagedObject) {
        let tag = object as! Tag
        cell.textLabel?.text = tag.name
        cell.selectionStyle = .None
        if note.tags.contains(tag) {
            tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
    }
    
    func deleteObject(object: NSManagedObject) {
        managedObjectContext.deleteObject(object)
    }
    
    func searchCancelled() {
        dismiss()
    }
    
    func didSearchForText(searchText: String, matches: [NSManagedObject]) {
        if searchText.characters.isEmpty || matches.count > 0 {
            setTableViewHeaderHidden(true)
        } else {
            setTableViewHeaderHidden(false)
        }
        headerView.textLabel.text = "\"\(searchText)\""
    }
    
}

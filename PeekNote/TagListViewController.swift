//
//  TagListViewController.swift
//  PeekNote
//
//  Created by Ahmed Onawale on 3/25/16.
//  Copyright © 2016 Ahmed Onawale. All rights reserved.
//

import UIKit
import CoreData

protocol TagListViewControllerDelegate: class {
    func tagListViewController(controller: TagListViewController, didSelectTag tag: Tag)
}

private let reuseIdentifier = "Tag Cell"

class TagListViewController: UITableViewController {
    
    private var textField: UITextField!
    weak var delegate: TagListViewControllerDelegate?
    var managedObjectContext: NSManagedObjectContext!
    var tableViewDataSource: UITableViewFRCDataSource!
    
    // Mark: - Fetched Results Controller
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Tag")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        return fetchedResultsController
    }()
    
    func dismiss() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func addTag() {
        guard let name = textField.text else { return }
        _ = Tag(name: name, insertIntoManagedObjectContext: managedObjectContext)
        managedObjectContext.saveContext()
        textField.text?.removeAll()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        textField = UITextField(frame: CGRect(origin: CGPointZero, size: CGSize(width: view.frame.width, height: 44)))
        textField.placeholder = "Add tag"
        textField.textColor = UIColor.whiteColor()
        navigationItem.titleView = textField
        textField.delegate = self
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.tableFooterView = UIView()
        
        tableViewDataSource = UITableViewFRCDataSource(tableView: tableView, reuseIdentifier: reuseIdentifier, fetchedResultsController: fetchedResultsController)
        tableViewDataSource.delegate = self

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(addTag))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: #selector(dismiss))
        navigationItem.rightBarButtonItem?.enabled = false
    }

}

extension TagListViewController: UITextFieldDelegate {
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
        navigationItem.rightBarButtonItem?.enabled = !newString.isEmpty
        return true
    }
}

extension TagListViewController {
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delegate?.tagListViewController(self, didSelectTag: fetchedResultsController.objectAtIndexPath(indexPath) as! Tag)
    }
}

extension TagListViewController: UITableViewFRCDataSourceDelegate {
    func tableViewFRCDataSource(dataSource: UITableViewFRCDataSource, configureCell cell: UITableViewCell, withObject object: NSManagedObject) {
        cell.textLabel?.text = (object as! Tag).name
    }
    
    func tableViewFRCDataSource(dataSource: UITableViewFRCDataSource, deleteObject object: NSManagedObject) {
        managedObjectContext.deleteObject(object)
        managedObjectContext.saveContext()
    }
}

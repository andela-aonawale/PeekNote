//
//  TableViewDataSource.swift
//  PeekNote
//
//  Created by Ahmed Onawale on 3/20/16.
//  Copyright © 2016 Ahmed Onawale. All rights reserved.
//

import Foundation
import CoreData
import UIKit

@objc protocol UITableViewFRCDataSourceDelegate: class {
    optional func titleForHeaderInSection(section: Int) -> String?
    optional func didChangeObject(anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?)
    optional func didSearchForText(searchText: String, matches: [NSManagedObject])
    optional func didSelectCell(cell: UITableViewCell, withObject object: NSManagedObject)
    optional func didDeselectCell(cell: UITableViewCell, withObject object: NSManagedObject)
    optional func deleteObject(object: NSManagedObject)
    optional func searchCancelled()
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath, withObject object: NSManagedObject)
}

class UITableViewFRCDataSource: NSObject {
    
    // MARK: - Properties
    var reuseIdentifier: String
    var tableView: UITableView
    var fetchedResultsController: NSFetchedResultsController!
    weak var delegate: UITableViewFRCDataSourceDelegate?
    
    // MARK: - Initialization
    init(tableView: UITableView, reuseIdentifier: String, fetchedResultsController: NSFetchedResultsController) {
        self.tableView = tableView
        self.reuseIdentifier = reuseIdentifier
        self.fetchedResultsController = fetchedResultsController
        super.init()
        self.tableView.dataSource = self
        fetchedResultsController.delegate = self
        performFetch()
    }
    
    func performFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("fetchedResultsController error: \(error)")
        }
    }
    
}

extension UITableViewFRCDataSource: UITableViewDataSource {
    
    // MARK: - Table View data source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)
        let object = fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject
        delegate?.configureCell(cell, atIndexPath: indexPath, withObject: object)
        return cell
    }
    
}

extension UITableViewFRCDataSource: NSFetchedResultsControllerDelegate {
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
        case .Delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
        case .Update, .Move:
            break
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Left)
        case .Update:
            tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        }
        delegate?.didChangeObject?(anObject, atIndexPath: indexPath, forChangeType: type, newIndexPath: newIndexPath)
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
}
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
    optional func  tableViewFRCDataSource(dataSource: UITableViewFRCDataSource, deleteObject object: NSManagedObject)
    func tableViewFRCDataSource(dataSource: UITableViewFRCDataSource, configureCell cell: UITableViewCell, withObject object: NSManagedObject)
}

class UITableViewFRCDataSource: NSObject {
    
    // MARK: - Properties
    private var reuseIdentifier: String
    private var tableView: UITableView
    private var fetchedResultsController: NSFetchedResultsController!
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
    
    private func performFetch() {
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
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)
        let object = fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject
        delegate?.tableViewFRCDataSource(self, configureCell: cell, withObject: object)
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let object = fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject
            delegate?.tableViewFRCDataSource?(self, deleteObject: object)
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
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
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        case .Update:
            tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
            tableView.insertRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
}
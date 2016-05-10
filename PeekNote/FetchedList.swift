//
//  FetchedList.swift
//  PeekNote
//
//  Created by Ahmed Onawale on 5/6/16.
//  Copyright © 2016 Ahmed Onawale. All rights reserved.
//

import UIKit
import CoreData

protocol FetchedList: List, NSFetchedResultsControllerDelegate {
    var fetchedResultsController: NSFetchedResultsController { get set }
}

extension FetchedList {
    var numberOfSections: Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    var sectionIndexTitles: [AnyObject]? {
        return fetchedResultsController.sectionIndexTitles
    }

    func numberOfRowsInSection(section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func indexPathIsValid(indexPath: NSIndexPath) -> Bool {
        guard indexPath.section < numberOfSections && indexPath.section >= 0 else {
            return false
        }
        return indexPath.row < numberOfRowsInSection(indexPath.section) && indexPath.row >= 0
    }
    
    func objectAtIndexPath(indexPath: NSIndexPath) -> AnyObject? {
        guard indexPathIsValid(indexPath) else { return nil }
        return fetchedResultsController.objectAtIndexPath(indexPath)
    }
    
    func titleForHeaderInSection(section: Int) -> String? {
        guard indexPathIsValid(NSIndexPath(forRow: 0, inSection: section)) else { return nil }
        return fetchedResultsController.sections?[section].name
    }
    
    func performFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch {}
    }
}

protocol FetchedTableList: FetchedList, UITableViewDataSource, UITableViewDelegate {
    var tableView: UITableView! { get set }
}

extension FetchedTableList where ListView == UITableView, Cell == UITableViewCell, Element == NSManagedObject {
    func tableCellAtIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = cellIdentifierForIndexPath(indexPath)
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath)
        if let element = objectAtIndexPath(indexPath) as? NSManagedObject {
            listView(tableView, configureCell: cell, withElement: element, atIndexPath: indexPath)
        }
        return cell
    }
}

extension FetchedTableList where ListView == UITableView, Cell == UITableViewCell, Element == NSManagedObject {
    func tableWillChangeContent() {
        tableView.beginUpdates()
    }
    
    func tableDidChangeSection(sectionIndex: Int, withChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
        case .Delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
        case .Update:
            tableView.reloadSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
        default:
            break
        }
    }
    
    func tableDidChangeObjectAtIndexPath(indexPath: NSIndexPath?, withChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        case .Update:
            tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        case .Move:
            tableView.moveRowAtIndexPath(indexPath!, toIndexPath: newIndexPath!)
        }
    }
    
    func tableDidChangeContent() {
        tableView.endUpdates()
    }
}





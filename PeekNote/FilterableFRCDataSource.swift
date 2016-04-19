//
//  FilterableFRCDataSource.swift
//  PeekNote
//
//  Created by Ahmed Onawale on 3/26/16.
//  Copyright © 2016 Ahmed Onawale. All rights reserved.
//

import Foundation
import CoreData
import UIKit

final class FilterableFRCDataSource: UITableViewFRCDataSource {
    
    var filteredObjects = [NSManagedObject]()
    var searchBar: UISearchBar!
    
    init(tableView: UITableView, reuseIdentifier: String, fetchedResultsController: NSFetchedResultsController, searchBar: UISearchBar) {
        self.searchBar = searchBar
        super.init(tableView: tableView, reuseIdentifier: reuseIdentifier, fetchedResultsController: fetchedResultsController)
        self.searchBar.delegate = self
        searchBar.sizeToFit()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchBar.isFirstResponder() {
            return filteredObjects.count ?? 0
        } else {
            let sectionInfo = fetchedResultsController.sections![section]
            return sectionInfo.numberOfObjects
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if searchBar.isFirstResponder() {
            return fetchedResultsController.sections?.count ?? 0
        } else {
            return 1
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)
        var object: NSManagedObject
        if searchBar.isFirstResponder() {
            object = filteredObjects[indexPath.row]
        } else {
            object = fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject
        }
        delegate?.configureCell(cell, atIndexPath: indexPath, withObject: object)
        return cell
    }
    
}

extension FilterableFRCDataSource: UISearchBarDelegate {
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        let searchPredicate = NSPredicate(format: "name contains[c] %@", searchText)
        filteredObjects = fetchedResultsController.fetchedObjects?.filter {
            searchPredicate.evaluateWithObject($0)
        } as! [NSManagedObject]
        if filteredObjects.isEmpty {
            filteredObjects = fetchedResultsController.fetchedObjects as! [NSManagedObject]
        }
        let predicate = NSPredicate(format: "name == %@", searchText)
        let matches = filteredObjects.filter { predicate.evaluateWithObject($0) }
        delegate?.didSearchForText?(searchText, matches: matches)
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        delegate?.searchCancelled?()
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        filteredObjects = fetchedResultsController.fetchedObjects as! [NSManagedObject]
    }
    
}
//
//  UICollectionViewFRCDataSource.swift
//  PeekNote
//
//  Created by Ahmed Onawale on 3/24/16.
//  Copyright © 2016 Ahmed Onawale. All rights reserved.
//

import Foundation
import CoreData
import UIKit

protocol UICollectionViewFRCDataSourceDelegate: class {
    func deleteObject(object: NSManagedObject)
    func configureCell(cell: UICollectionViewCell, withObject object: NSManagedObject)
}

class UICollectionViewFRCDataSource: NSObject {
    
    // MARK: - Properties
    private var reuseIdentifier: String
    private var collectionView: UICollectionView
    private var fetchedResultsController: NSFetchedResultsController!
    weak var delegate: UICollectionViewFRCDataSourceDelegate?
    
    private var insertedIndexPaths: [NSIndexPath]!
    private var deletedIndexPaths: [NSIndexPath]!
    private var updatedIndexPaths: [NSIndexPath]!
    
    // MARK: - Initialization
    init(collectionView: UICollectionView, reuseIdentifier: String, fetchedResultsController: NSFetchedResultsController) {
        self.collectionView = collectionView
        self.reuseIdentifier = reuseIdentifier
        self.fetchedResultsController = fetchedResultsController
        super.init()
        self.collectionView.dataSource = self
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

extension UICollectionViewFRCDataSource: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)
        delegate?.configureCell(cell, withObject: fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject)
        return cell
    }
    
}

extension UICollectionViewFRCDataSource: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths = [NSIndexPath]()
        updatedIndexPaths = [NSIndexPath]()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type{
        case .Insert:
            insertedIndexPaths.append(newIndexPath!)
        case .Delete:
            deletedIndexPaths.append(indexPath!)
        case .Update:
            updatedIndexPaths.append(indexPath!)
        case .Move:
            break
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        collectionView.performBatchUpdates({ () -> Void in
            self.collectionView.insertItemsAtIndexPaths(self.insertedIndexPaths)
            self.collectionView.deleteItemsAtIndexPaths(self.deletedIndexPaths)
            self.collectionView.reloadItemsAtIndexPaths(self.updatedIndexPaths)
        }) { finished in
//            CoreDataStackManager.sharedInstance().saveContext()
        }
    }
    
}
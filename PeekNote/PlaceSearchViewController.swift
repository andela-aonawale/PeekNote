//
//  SearchResultViewController.swift
//  PeekNote
//
//  Created by Ahmed Onawale on 4/8/16.
//  Copyright © 2016 Ahmed Onawale. All rights reserved.
//

import Foundation
import UIKit
import CoreData

private let reuseIdentifier = "Place Cell"

protocol PlaceSearchViewControllerDelegate: class {
    func searchViewController(controller: PlaceSearchViewController, didSelectPlace place: Place)
}

class PlaceSearchViewController: UIViewController {
    
    var persistentStoreCoordinator: NSPersistentStoreCoordinator!
    private var tableView: UITableView!
    private var searchBar: UISearchBar!
    private var predictions = [Place]()
    private var temporaryContext: NSManagedObjectContext!
    weak var delegate: PlaceSearchViewControllerDelegate?
    
    func configureTableView() {
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        let t1 = NSLayoutConstraint(item: tableView, attribute: .Top, relatedBy: .Equal, toItem: searchBar, attribute: .Bottom, multiplier: 1, constant: 8)
        let t2 = NSLayoutConstraint(item: tableView, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1, constant: 0)
        let t3 = NSLayoutConstraint(item: tableView, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1, constant: 0)
        let t4 = NSLayoutConstraint(item: tableView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        view.addConstraints([t1, t2, t3, t4])
        tableView.tableFooterView = UIView()
    }
    
    func configureSearchBar() {
        searchBar = UISearchBar()
        searchBar.delegate = self
        let s1 = NSLayoutConstraint(item: searchBar, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: 0)
        let s2 = NSLayoutConstraint(item: searchBar, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1, constant: 0)
        let s3 = NSLayoutConstraint(item: searchBar, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1, constant: 0)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)
        view.addConstraints([s1, s2, s3])
    }
    
    func configureSegmentedControl() {
        let segment = UISegmentedControl(items: [Trigger.OnEntry.title(), Trigger.OnExit.title()])
        segment.selectedSegmentIndex = 0
        segment.backgroundColor = .whiteColor()
        searchBar.inputAccessoryView = segment
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .whiteColor()
        
        configureSearchBar()
        configureTableView()
        configureSegmentedControl()
        
        temporaryContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        temporaryContext.persistentStoreCoordinator = persistentStoreCoordinator
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidDisappear(animated)
        searchBar.becomeFirstResponder()
        searchBar.inputAccessoryView?.hidden = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        searchBar.resignFirstResponder()
        searchBar.inputAccessoryView?.hidden = true
    }

}

extension PlaceSearchViewController: UISearchBarDelegate {
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            predictions.removeAll()
            tableView.reloadSection(0)
        } else if Reachability.reachabilityForInternetConnection().isReachable() {
            suggestPlacesFrom(searchText)
        } else {
            let place = Place("Network unavailable.", context: temporaryContext)
            predictions = [place]
            tableView.reloadSection(0)
        }
    }
    
    private func suggestPlacesFrom(searchText: String) {
        showNetworkActivityIndicator(true)
        APIClient.sharedInstance.autocompletePlace(searchText) { [weak self] result, error in
            showNetworkActivityIndicator(false)
            guard let `self` = self else { return }
            guard let result = result where error == nil,
                let places = result["predictions"] as? [[String: AnyObject]] else {
                let place = Place("No results found.", context: self.temporaryContext)
                self.predictions = [place]
                self.tableView.reloadSection(0)
                return
            }
            self.predictions = places.map() { Place($0, insertIntoManagedObjectContext: self.temporaryContext) }
            self.tableView.reloadSection(0)
        }
    }
    
}

extension PlaceSearchViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return predictions.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as UITableViewCell!
        if cell == nil {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: reuseIdentifier)
            cell.imageView?.image = UIImage(named: "Pin")
        }
        let place = predictions[indexPath.row]
        cell.textLabel?.text = place.name
        cell.detailTextLabel?.text = place.region
        return cell
    }
    
}

extension PlaceSearchViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let place = predictions[indexPath.row]
        let index = (searchBar.inputAccessoryView as! UISegmentedControl).selectedSegmentIndex
        place.trigger = Trigger(rawValue: Int16(index))!
        delegate?.searchViewController(self, didSelectPlace: place)
        navigationController?.popViewControllerAnimated(true)
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if !Reachability.reachabilityForInternetConnection().isReachable() || predictions[indexPath.row].id.isEmpty {
            return nil
        }
        return indexPath
    }
    
}
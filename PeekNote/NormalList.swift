//
//  NormalList.swift
//  PeekNote
//
//  Created by Ahmed Onawale on 5/6/16.
//  Copyright © 2016 Ahmed Onawale. All rights reserved.
//

import UIKit

protocol NormalList: List {
    var elements: [[Element]] {get set}
}

extension NormalList {
    
    var numberOfSections: Int {
        return elements.count
    }
    
    func elementAtindexPath(indexPath: NSIndexPath) -> Element? {
        guard indexPathIsValid(indexPath) else {
            return nil
        }
        return elements[indexPath.section][indexPath.row]
    }
    
    func numberOfRowsInSection(section: Int) -> Int {
        return elements[section].count
    }
    
    func indexPathIsValid(indexPath: NSIndexPath) -> Bool {
        guard indexPath.section >= 0 && indexPath.section < elements.count else {
            return false
        }
        return indexPath.row >= 0 && indexPath.row < elements[indexPath.section].count
    }
    
}

protocol TableList: NormalList, UITableViewDataSource, UITableViewDelegate {
    var tableView: UITableView! { get set }
}

extension TableList where ListView == UITableView, Cell == UITableViewCell {
    
    func tableCellAtIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = cellIdentifierForIndexPath(indexPath)
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath)
        if let element = elementAtindexPath(indexPath) {
            listView(tableView, configureCell: cell, withElement: element, atIndexPath: indexPath)
        }
        return cell
    }
    
}
//
//  TagsCollectionViewController.swift
//  PeekNote
//
//  Created by Ahmed Onawale on 3/25/16.
//  Copyright © 2016 Ahmed Onawale. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Tag Cell"

class TagsCollectionViewController: UICollectionViewController {
    
    var sizingCell: TagCell?
    let tags = ["Tech", "Design", "Humor", "Travel", "Music", "Writing", "Social Media", "Life"]
    @IBOutlet weak var flowLayout: FlowLayout!

    override func viewDidLoad() {
        super.viewDidLoad()
        flowLayout.sectionInset = UIEdgeInsetsMake(8, 8, 8, 8)
        
        let tagCell = UINib(nibName: "TagCell", bundle: nil)
        sizingCell = tagCell.instantiateWithOwner(nil, options: nil).first as? TagCell
        
        collectionView?.registerNib(tagCell, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView?.backgroundColor = UIColor.clearColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        configureCell(sizingCell!, forIndexPath: indexPath)
        return sizingCell!.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
    }

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! TagCell
        configureCell(cell, forIndexPath: indexPath)
        return cell
    }
    
    func configureCell(cell: TagCell, forIndexPath indexPath: NSIndexPath) {
        let tag = tags[indexPath.row]
        cell.tagName.text = tag
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}

//
//  NoteTableViewCell.swift
//  PeekNote
//
//  Created by Ahmed Onawale on 3/20/16.
//  Copyright © 2016 Ahmed Onawale. All rights reserved.
//

import UIKit
import TagListView
import MCSwipeTableViewCell

class NoteTableViewCell: MCSwipeTableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var body: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var tagListView: TagListView!
    
    var note: Note! {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        guard note != nil else { return }
        title.text = note.title
        body.text = note.body
        date.text = note.creationDate.prettified
        tagListView.removeAllTags()
        note.tags.forEach { tagListView.addTag($0.name) }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tagListView.alignment = .Right
    }
    
}
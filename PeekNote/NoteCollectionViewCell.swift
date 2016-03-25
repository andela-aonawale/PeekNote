//
//  NoteCollectionViewCell.swift
//  PeekNote
//
//  Created by Ahmed Onawale on 3/24/16.
//  Copyright © 2016 Ahmed Onawale. All rights reserved.
//

import UIKit

class NoteCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var body: UILabel!
    @IBOutlet weak var date: UILabel!
    
    var note: Note! {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        guard note != nil else { return }
        title.text = note.title
        body.text = note.body
        date.text = note.createdDateString
    }
    
}

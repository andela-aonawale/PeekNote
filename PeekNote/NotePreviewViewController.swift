//
//  NotePreviewViewController.swift
//  PeekNote
//
//  Created by Ahmed Onawale on 3/27/16.
//  Copyright © 2016 Ahmed Onawale. All rights reserved.
//

import UIKit
import TagListView

class NotePreviewViewController: UIViewController {
    
    var note: Note!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleTextFiled: UITextField!
    @IBOutlet weak var bodyTextView: UILabel!
    @IBOutlet weak var tagListView: TagListView!
    
    func configureView() {
        guard note != nil else { return }
        titleTextFiled.text = note.title
        bodyTextView.text = note.body
        dateLabel.text = note.createdDateString
        tagListView.alignment = .Right
        note.tags.forEach { tagListView.addTag($0.name) }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

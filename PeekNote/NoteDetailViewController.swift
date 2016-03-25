//
//  DetailViewController.swift
//  PeekNote
//
//  Created by Ahmed Onawale on 3/20/16.
//  Copyright © 2016 Ahmed Onawale. All rights reserved.
//

import UIKit
import CoreData

protocol NoteDetailViewControllerDelegate: class {
    func noteDetailViewController(controller: NoteDetailViewController, didEndEditingNote note: Note)
}

class NoteDetailViewController: UIViewController {

    var note: Note!
    var managedObjectContext: NSManagedObjectContext!
    weak var delegate: NoteDetailViewControllerDelegate?
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleTextFiled: UITextField!
    @IBOutlet weak var bodyTextView: UITextView!

    func configureView() {
        guard note != nil else { return }
        titleTextFiled.text = note.title
        bodyTextView.text = note.body
        dateLabel.text = note.createdDateString
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
        note.title = titleTextFiled.text!
        note.body = bodyTextView.text
        delegate?.noteDetailViewController(self, didEndEditingNote: note)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
        navigationItem.leftItemsSupplementBackButton = true
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func showTags(sender: UIBarButtonItem) {
        let vc = TagListViewController(style: .Plain)
        vc.managedObjectContext = managedObjectContext
        vc.delegate = self
        let navCon = UINavigationController(rootViewController: vc)
        presentViewController(navCon, animated: true, completion: nil)
    }

}

extension NoteDetailViewController: TagListViewControllerDelegate {
    func tagListViewController(controller: TagListViewController, didSelectTag tag: Tag) {
        print(tag)
    }
}
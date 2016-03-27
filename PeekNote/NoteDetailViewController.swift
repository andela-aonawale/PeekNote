//
//  DetailViewController.swift
//  PeekNote
//
//  Created by Ahmed Onawale on 3/20/16.
//  Copyright © 2016 Ahmed Onawale. All rights reserved.
//

import UIKit
import CoreData
import TagListView

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
    @IBOutlet weak var tagListView: TagListView!
    @IBOutlet weak var remindButton: UIButton!
    @IBOutlet weak var deleteReminderButton: UIButton!
    
    func configureView() {
        guard note != nil else { return }
        titleTextFiled.text = note.title
        bodyTextView.text = note.body
        dateLabel.text = note.createdDateString
        tagListView.alignment = .Right
        navigationItem.rightBarButtonItem?.enabled = !note.title.isEmpty || !note.body.isEmpty
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
        guard presentedViewController == nil else { return }
        note.title = titleTextFiled.text!
        note.body = bodyTextView.text
        delegate?.noteDetailViewController(self, didEndEditingNote: note)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tagListView.removeAllTags()
        note.tags.forEach { tagListView.addTag($0.name) }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
        navigationItem.leftItemsSupplementBackButton = true
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func showTags(sender: UIBarButtonItem) {
        let vc = TagListViewController(style: .Plain)
        vc.managedObjectContext = managedObjectContext
        vc.note = note
        let navCon = UINavigationController(rootViewController: vc)
        presentViewController(navCon, animated: true, completion: nil)
    }
    
    @IBAction func addReminder(sender: UIButton) {
        // TODO: add reminder to note
    }
    
    @IBAction func deleteReminder(sender: UIButton) {
        // TODO: delete reminder from note
    }
    
    @IBAction func textDidChange(sender: UITextField) {
        canAddTagToNote()
    }
    
    func canAddTagToNote() -> Bool {
        navigationItem.rightBarButtonItem?.enabled = !titleTextFiled.text!.isEmpty || !bodyTextView.text.isEmpty
        return true
    }

}

extension NoteDetailViewController: UITextViewDelegate {
    
    func textViewDidChange(textView: UITextView) {
        canAddTagToNote()
    }
    
}

extension NoteDetailViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        view.endEditing(true)
    }

}
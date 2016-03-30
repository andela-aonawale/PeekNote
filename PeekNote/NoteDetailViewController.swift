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

class NoteDetailViewController: UIViewController {

    var note: Note!
    var managedObjectContext: NSManagedObjectContext!
    
    @IBOutlet weak var scrollView: UIScrollView!
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
        dateLabel.text = note.creationDate.prettified
        tagListView.alignment = .Right
        navigationItem.rightBarButtonItem?.enabled = !note.title.isEmpty || !note.body.isEmpty
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeToKeyboardNotifications()
        view.endEditing(true)
        // make sure we are returning to NotesViewController
        // and not presenting tags view controller
        guard presentedViewController == nil else { return }
        guard note != nil else { return }
        note.title = titleTextFiled.text!
        note.body = bodyTextView.text
        if note.title.isEmpty && note.body.isEmpty {
            managedObjectContext.deleteObject(note)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        guard note != nil else { return }
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
        let viewController = TagListViewController(style: .Plain)
        viewController.managedObjectContext = managedObjectContext
        viewController.note = note
        let navCon = UINavigationController(rootViewController: viewController)
        navCon.modalPresentationStyle = .Popover
        let ppc = navCon.popoverPresentationController
        ppc?.barButtonItem = navigationItem.rightBarButtonItem        
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

extension NoteDetailViewController {
    
    // MARK: - NoteDetailViewController (Show/Hide Keyboard)
    
    func subscribeToKeyboardNotifications() {
        let center = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let keyboardHeight = keyboardHeightFromNotification(notification)

        // add the keyboard height to the content insets so that the scrollview can be scrolled
        let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = contentInset
    }
    
    func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = UIEdgeInsetsZero
        scrollView.scrollIndicatorInsets = UIEdgeInsetsZero
    }
    
    func keyboardHeightFromNotification(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardFrame = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardFrame.CGRectValue().height
    }
}
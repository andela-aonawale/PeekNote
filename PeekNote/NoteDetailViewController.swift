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

final class NoteDetailViewController: UIViewController {

    var note: Note!
    var managedObjectContext: NSManagedObjectContext!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleTextFiled: UITextField!
    @IBOutlet weak var bodyTextView: UITextView!
    @IBOutlet weak var tagListView: TagListView!
    @IBOutlet weak var reminderLabel: UILabel!
    @IBOutlet weak var remindButton: UIButton!
    @IBOutlet weak var deleteReminderButton: UIButton!
    
    func configureView() {
        guard note != nil else { return }
        titleTextFiled.text = note.title
        bodyTextView.text = note.body
        dateLabel.text = note.creationDate.prettified
        tagListView.alignment = .Right
        checkIfNoteIsValid()
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
        note.updatedDate = NSDate()
        if note.title.isEmpty && note.body.isEmpty {
            managedObjectContext.deleteObject(note)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        guard note != nil else { return }
        subscribeToKeyboardNotifications()
        tagListView.removeAllTags()
        note.tags.forEach { tagListView.addTag($0.name) }
        guard let reminder = note.reminder else { return }
        reminderLabel.text = String.mediumDateShortTime(reminder.date)
        reminderLabel.text = reminderLabel.text?.stringByAppendingString("\nRepeats: \(reminder.repeats.title())")
        reminderLabel.textColor = .lightGrayColor()
        reminderLabel.font = .systemFontOfSize(14)
        remindButton.setImage(UIImage(named: "Alarm Clock"), forState: .Normal)
        deleteReminderButton.enabled = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        guard note != nil else { return }
        if note.title.isEmpty && note.body.isEmpty {
            bodyTextView.becomeFirstResponder()
        }
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
    
    @IBAction func addReminder(sender: UITapGestureRecognizer) {
        let viewController = AddReminderViewController()
        viewController.note = note
        viewController.managedObjectContext = managedObjectContext
        let navCon = UINavigationController(rootViewController: viewController)
        presentViewController(navCon, animated: true) {
            let settings = UIUserNotificationSettings( forTypes: [.Alert, .Sound, .Badge], categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        }
    }
    
    @IBAction func deleteReminder(sender: UIButton) {
        guard let reminder = note.reminder else { return }
        managedObjectContext.deleteObject(reminder)
        reminderLabel.text = "Remind me"
        reminderLabel.font = .systemFontOfSize(17)
        reminderLabel.textColor = .secondaryColor()
        remindButton.setImage(UIImage(named: "Reminder"), forState: .Normal)
        sender.enabled = false
    }
    
    @IBAction func textDidChange(sender: UITextField) {
        checkIfNoteIsValid()
    }
    
    func checkIfNoteIsValid() {
        let enable = !titleTextFiled.text!.isEmpty || !bodyTextView.text.isEmpty
        navigationItem.rightBarButtonItem?.enabled = enable
        reminderLabel.userInteractionEnabled = enable
        reminderLabel.textColor = enable ? .secondaryColor() : .lightGrayColor()
        remindButton.enabled = enable
    }

}

extension NoteDetailViewController: UITextViewDelegate {
    
    func textViewDidChange(textView: UITextView) {
        checkIfNoteIsValid()
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
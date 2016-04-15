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

protocol PreviewControllerDelegate: class {
    func tagNote(note: Note)
    func shareNote(note: Note)
    func addReminderToNote(note: Note)
    func deleteNote(note: Note)
}

final class NoteDetailViewController: UIViewController {

    var note: Note!
    var managedObjectContext: NSManagedObjectContext!
    
    private enum PreviewAction: String {
        case Tag
        case RemindMe = "Remind me"
        case Share
        case Delete
    }
    
    weak var delegate: PreviewControllerDelegate?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleTextFiled: UITextField!
    @IBOutlet weak var bodyTextView: UITextView!
    @IBOutlet weak var tagListView: TagListView!
    @IBOutlet weak var reminderLabel: UILabel!
    @IBOutlet weak var remindButton: UIButton!
    @IBOutlet weak var deleteReminderButton: UIButton!
    
    // Preview action items.
    @available(iOS 9.0, *)
    lazy var previewActions: [UIPreviewActionItem] = {
        func previewActionForTitle(title: String, style: UIPreviewActionStyle = .Default) -> UIPreviewAction {
            return UIPreviewAction(title: title, style: style) { previewAction, viewController in
                guard let detailViewController = viewController as? NoteDetailViewController,
                note = detailViewController.note,
                previewAction = PreviewAction(rawValue: previewAction.title) else { return }
                switch previewAction {
                case .Tag:
                    detailViewController.delegate?.tagNote(note)
                case .Share:
                    detailViewController.delegate?.shareNote(note)
                case .RemindMe:
                    detailViewController.delegate?.addReminderToNote(note)
                case .Delete:
                    detailViewController.delegate?.deleteNote(note)
                }
            }
        }
        
        let action1 = previewActionForTitle(PreviewAction.Tag.rawValue)
        let action2 = previewActionForTitle(PreviewAction.Share.rawValue)
        let action3 = previewActionForTitle(PreviewAction.RemindMe.rawValue)
        let action4 = previewActionForTitle(PreviewAction.Delete.rawValue, style: .Destructive)
        
        return [action1, action2, action3, action4]
    }()
    
    // MARK: Preview actions
    
    @available(iOS 9.0, *)
    override func previewActionItems() -> [UIPreviewActionItem] {
        return previewActions
    }
    
    @IBAction func shareNote(sender: UIBarButtonItem) {
        let activityViewController = UIActivityViewController(activityItems: [note.shareableString], applicationActivities: nil)
        presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    // MARK: Life cycle

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeToKeyboardNotifications()
        guard note != nil else { return }
        view.endEditing(true)
        // make sure we are returning to NotesViewController
        // and not presenting tags view controller
        guard presentedViewController == nil else { return }
        if note.title.isEmpty && note.body.isEmpty {
            managedObjectContext.deleteObject(note)
        } else if note.hasChanges {
            note.updatedDate = NSDate()
            managedObjectContext.saveChanges()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        guard note != nil else { return }
        tagListView.removeAllTags()
        note.tags.forEach { tagListView.addTag($0.name) }
        
        guard let reminder = note.reminder else { return }
        if let place = reminder.place {
            reminderLabel.text = place.trigger.title()
            reminderLabel.text = reminderLabel.text?.stringByAppendingString("\n\(place.name), \(place.region)")
        } else {
            reminderLabel.text = String.mediumDateShortTime(reminder.date)
            reminderLabel.text = reminderLabel.text?.stringByAppendingString("\nRepeats: \(reminder.repeats.title())")
        }
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
        guard note != nil else { return }
        titleTextFiled.text = note.title
        bodyTextView.text = note.body
        dateLabel.text = note.creationDate.prettified
        tagListView.alignment = .Right
        checkIfNoteIsValid()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func showTags(sender: UIBarButtonItem) {
        let viewController = TagListViewController(managedObjectContext: managedObjectContext, note: note)
        presentViewController(viewController, barButtonItem: navigationItem.rightBarButtonItem, completion: nil)
    }
    
    @IBAction func addReminder(sender: UITapGestureRecognizer) {
        let viewController = AddReminderViewController(managedObjectContext: managedObjectContext, note: note)
        presentViewController(viewController, barButtonItem: nil) {
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
        note.title = sender.text!
        checkIfNoteIsValid()
    }
    
    func checkIfNoteIsValid() {
        let enable = !note.title.isEmpty || !note.body.isEmpty
        navigationItem.rightBarButtonItems?.first?.enabled = enable
        navigationItem.rightBarButtonItems?.last?.enabled = enable
        reminderLabel.userInteractionEnabled = enable
        reminderLabel.textColor = enable ? .secondaryColor() : .lightGrayColor()
        remindButton.enabled = enable
    }

}

extension NoteDetailViewController: UITextViewDelegate {
    
    func textViewDidChange(textView: UITextView) {
        note.body = textView.text
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
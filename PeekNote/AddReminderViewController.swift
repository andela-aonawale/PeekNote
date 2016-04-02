//
//  AddReminderViewController.swift
//  PeekNote
//
//  Created by Ahmed Onawale on 3/31/16.
//  Copyright © 2016 Ahmed Onawale. All rights reserved.
//

import UIKit
import Former
import CoreData

@objc enum Repeat: Int16 {
    case Never, Daily, Weekly, Monthly, Yearly
    func title() -> String {
        switch self {
        case Never: return "Never"
        case Daily: return "Every Day"
        case Weekly: return "Every Week"
        case Monthly: return "Every Month"
        case Yearly: return "Every Year"
        }
    }
    func calendarUnit() -> NSCalendarUnit {
        switch self {
        case Never: return NSCalendarUnit(rawValue: 0)
        case Daily: return NSCalendarUnit.Day
        case Weekly: return NSCalendarUnit.Weekday
        case Monthly: return NSCalendarUnit.WeekOfMonth
        case Yearly: return NSCalendarUnit.WeekOfYear
        }
    }
    init(_ value: String) {
        switch value {
        case "Every Day": self = .Daily
        case "Every Week": self = .Weekly
        case "Every Month": self = .Monthly
        case "Every Year": self = .Yearly
        default: self = .Never
        }
    }
    static func values() -> [Repeat] {
        return [Never, Daily, Weekly, Monthly, Yearly]
    }
}

class AddReminderViewController: FormViewController {
    
    var note: Note!
    private var repeats: Repeat!
    private var date: NSDate!
    var managedObjectContext: NSManagedObjectContext!
    
    func done() {
        if let reminder = note.reminder {
            reminder.date = date
            reminder.repeats = repeats
            reminder.scheduleNotification()
        } else {
            let reminder = Reminder(date: date, repeats: repeats, insertIntoManagedObjectContext: managedObjectContext)
            note.reminder = reminder
        }
        dismiss()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add Reminder"
        repeats = note.reminder?.repeats ?? .Never
        date = note.reminder?.date ?? NSDate.nextHourDate
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(done))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(dismiss))
        
        tableView.contentInset.top = 10
        tableView.contentInset.bottom = 30
        tableView.contentOffset.y = -10
        
        let dateRow = InlineDatePickerRowFormer<FormInlineDatePickerCell>() {
            $0.titleLabel.text = "Date"
            $0.titleLabel.textColor = .blackColor()
            $0.titleLabel.font = .boldSystemFontOfSize(15)
            $0.displayLabel.textColor = .secondaryColor()
            $0.displayLabel.font = .systemFontOfSize(15)
        }.inlineCellSetup {
            $0.datePicker.datePickerMode = .DateAndTime
        }.configure {
            $0.date = self.date
            $0.displayEditingColor = .highlightedColor()
        }.displayTextFromDate(String.mediumDateShortTime)
        .onDateChanged { [weak self] in
            self?.date = $0
        }
        
        // Create Headers
        let createHeader: (() -> ViewFormer) = {
            return CustomViewFormer<FormHeaderFooterView>()
                .configure {
                    $0.viewHeight = 20
            }
        }
        
        // Selector
        
        let createSelectorRow = { (
            text: String,
            subText: Repeat,
            onSelected: (RowFormer -> Void)?
            ) -> RowFormer in
            return LabelRowFormer<FormLabelCell>() {
                $0.titleLabel.textColor = .secondaryColor()
                $0.titleLabel.font = .boldSystemFontOfSize(16)
                $0.subTextLabel.textColor = .subSecondaryColor()
                $0.subTextLabel.font = .boldSystemFontOfSize(14)
                $0.accessoryType = .DisclosureIndicator
                }.configure { form in
                    _ = onSelected.map { form.onSelected($0) }
                    form.text = text
                    form.subText = subText.title()
            }
        }
        let options = Repeat.values() //["Never", "Every Day", "Every Week", "Every 2 Weeks", "Every Month", "Every Year"]
        
        let pushSelectorRow = createSelectorRow("Repeat", repeats, pushSelectorRowSelected(options))
        
        // Create SectionFormers
        let dateSection = SectionFormer(rowFormer: dateRow, pushSelectorRow)
            .set(headerViewFormer: createHeader())
        
        former.append(sectionFormer: dateSection)
    }
    
    private func pushSelectorRowSelected(options: [Repeat]) -> RowFormer -> Void {
        return { [weak self] rowFormer in
            if let rowFormer = rowFormer as? LabelRowFormer<FormLabelCell> {
                let controller = TextSelectorViewContoller()
                controller.texts = options
                controller.selectedText = Repeat(rowFormer.subText!)
                controller.onSelected = {
                    rowFormer.subText = $0.title()
                    self?.repeats = $0
                    rowFormer.update()
                }
                self?.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private final class TextSelectorViewContoller: FormViewController {
        
        // MARK: Public
        
        private var texts = [Repeat]() {
            didSet {
                reloadForm()
            }
        }
        
        private var selectedText: Repeat? {
            didSet {
                former.rowFormers.forEach {
                    if let LabelRowFormer = $0 as? LabelRowFormer<FormLabelCell>
                        where LabelRowFormer.text == selectedText?.title() {
                        LabelRowFormer.cellUpdate({ $0.accessoryType = .Checkmark })
                    }
                }
            }
        }
        
        private var onSelected: (Repeat -> Void)?
        
        private func reloadForm() {
            
            // Create RowFormers
            
            let rowFormers = texts.map { text -> LabelRowFormer<FormLabelCell> in
                return LabelRowFormer<FormLabelCell>() { [weak self] in
                    if let sSelf = self {
                        $0.titleLabel.textColor = .secondaryColor()
                        $0.titleLabel.font = .boldSystemFontOfSize(16)
                        $0.tintColor = .subSecondaryColor()
                        $0.accessoryType = (text == sSelf.selectedText) ? .Checkmark : .None
                    }
                    }.configure {
                        $0.text = text.title()
                    }.onSelected { [weak self] _ in
                        self?.onSelected?(text)
                        self?.navigationController?.popViewControllerAnimated(true)
                }
            }
            
            // Create SectionFormers
            
            let sectionFormer = SectionFormer(rowFormers: rowFormers)
            
            former.removeAll().append(sectionFormer: sectionFormer).reload()
        }
    }

}
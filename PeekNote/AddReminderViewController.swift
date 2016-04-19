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
import CoreLocation

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
        case Weekly: return NSCalendarUnit.WeekOfYear
        case Monthly: return NSCalendarUnit.Month
        case Yearly: return NSCalendarUnit.Year
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

protocol AddReminderViewControllerDelegate: class {
    func addReminderViewController(controller: AddReminderViewController, didFinishPickingReminder reminder: Reminder)
}

class AddReminderViewController: FormViewController {
    
    let note: Note
    private var repeats: Repeat!
    private var date: NSDate!
    weak var delegate: AddReminderViewControllerDelegate?
    
    private var place: Place? {
        didSet {
            guard let place = oldValue else { return }
            managedObjectContext.deleteObject(place)
        }
    }
    
    let managedObjectContext: NSManagedObjectContext
    
    init(managedObjectContext: NSManagedObjectContext, note: Note) {
        self.managedObjectContext = managedObjectContext
        self.note = note
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func done() {
        if let reminder = note.reminder {
            reminder.date = date
            reminder.place = place
            reminder.repeats = repeats
            reminder.scheduleNotification()
            delegate?.addReminderViewController(self, didFinishPickingReminder: reminder)
        } else {
            let reminder = Reminder(date: date, note: note, repeats: repeats, insertIntoManagedObjectContext: managedObjectContext)
            reminder.place = place
            reminder.scheduleNotification()
            delegate?.addReminderViewController(self, didFinishPickingReminder: reminder)
        }
        dismiss()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add Reminder"
        repeats = note.reminder?.repeats ?? .Never
        date = note.reminder?.date ?? NSDate.nextHourDate
        place = note.reminder?.place
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(done))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(dismiss))
        
        tableView.contentInset.top = 10
        tableView.contentInset.bottom = 30
        tableView.contentOffset.y = -10
        
        let dateRow = InlineDatePickerRowFormer<FormInlineDatePickerCell>() {
            $0.titleLabel.text = "Date"
            $0.titleLabel.textColor = .textColor()
            $0.titleLabel.font = .systemFontOfSize(17)
            $0.displayLabel.textColor = .subTextColor()
            $0.displayLabel.font = .systemFontOfSize(17)
        }.inlineCellSetup {
            $0.datePicker.datePickerMode = .DateAndTime
        }.configure {
            $0.date = self.date
            $0.displayEditingColor = .primaryColor()
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
                $0.titleLabel.textColor = .textColor()
                $0.titleLabel.font = .systemFontOfSize(17)
                $0.subTextLabel.textColor = .secondaryColor()
                $0.subTextLabel.font = .systemFontOfSize(17)
                $0.accessoryType = .DisclosureIndicator
                }.configure { form in
                    _ = onSelected.map { form.onSelected($0) }
                    form.text = text
                    form.subText = subText.title()
                }
        }
        let options = Repeat.values() //["Never", "Every Day", "Every Week", "Every 2 Weeks", "Every Month", "Every Year"]
        
        let pushSelectorRow = createSelectorRow("Repeat", repeats, pushSelectorRowSelected(options))
        
        let locationRow = SwitchRowFormer<FormSwitchCell>() {
            $0.titleLabel.text = "Remind me at a location"
            $0.titleLabel.textColor = .textColor()
            $0.titleLabel.font = .systemFontOfSize(17)
            $0.switchButton.onTintColor = .primaryColor()
        }.configure { form in
            form.switched = place != nil
        }
        
        // Create SectionFormers
        let locationSection = SectionFormer(rowFormer: locationRow)
            .set(headerViewFormer: createHeader())
        
        let dateSection = SectionFormer(rowFormer: dateRow, pushSelectorRow)
            .set(headerViewFormer: createHeader())
        
        locationRow.onSwitchChanged(insertRows(sectionTop: locationSection.firstRowFormer!, sectionBottom: locationSection.lastRowFormer!))
        
        former.append(sectionFormer: dateSection, locationSection)
        
        if note.reminder?.place != nil {
            former.insert(rowFormer: subRowFormers, below: locationRow)
        }
    }
    
    private lazy var subRowFormers: RowFormer = {
        return LabelRowFormer<FormLabelCell>() {
            $0.titleLabel.textColor = .textColor()
            $0.titleLabel.font = .systemFontOfSize(17)
            $0.subTextLabel.textColor = .secondaryColor()
            $0.subTextLabel.font = .systemFontOfSize(17)
            $0.accessoryType = .DisclosureIndicator
            }.configure { form in
                form.text = "Location"
                form.subText = self.place?.name
            }.onSelected { [weak self] _ in
                let vc = PlaceSearchViewController()
                vc.persistentStoreCoordinator = self?.managedObjectContext.persistentStoreCoordinator
                vc.delegate = self
                self?.navigationController?.pushViewController(vc, animated: true)
            }
    }()
    
    private func insertRows(sectionTop sectionTop: RowFormer, sectionBottom: RowFormer) -> Bool -> Void {
        return { [weak self] insert in
            guard let `self` = self else { return }
            if insert {
                self.former.insertUpdate(rowFormer: self.subRowFormers, below: sectionBottom, rowAnimation: .Top)
            } else {
                self.place = nil
                self.former.removeUpdate(rowFormer: self.subRowFormers, rowAnimation: .Top)
            }
        }
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
                        $0.titleLabel.textColor = .textColor()
                        $0.titleLabel.font = .systemFontOfSize(17)
                        $0.tintColor = .secondaryColor()
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

extension AddReminderViewController: PlaceSearchViewControllerDelegate {
    
    func placeSearchViewController(controller: PlaceSearchViewController, didSelectPlace place: Place) {
        APIClient.sharedInstance.lookUpPlaceWithID(place.id) { [weak self] result, error in
            guard let `self` = self else { return }
            guard let json = result?["result"] as? [String: AnyObject],
                geometry = json["geometry"] as? [String: AnyObject],
                location = geometry["location"],
                latitude = location["lat"] as? CLLocationDegrees,
                longitude = location["lng"] as? CLLocationDegrees else {
                return
            }
            self.place = Place.clone(place, insertIntoManagedObjectContext: self.managedObjectContext)
            self.place?.latitude = latitude
            self.place?.longitude = longitude
            guard let rowFormer = self.subRowFormers as? LabelRowFormer<FormLabelCell> else { return }
            rowFormer.subText = self.place?.name
            rowFormer.update()
        }
    }
    
}
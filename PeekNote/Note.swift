//
//  Note.swift
//  PeekNote
//
//  Created by Ahmed Onawale on 3/20/16.
//  Copyright © 2016 Ahmed Onawale. All rights reserved.
//

import Foundation
import CoreData

@objc enum State: Int16 {
    case Normal
    case Archived
    case Trashed
}

final class Note: NSManagedObject {
    
    @NSManaged var tags: Set<Tag>
    @NSManaged var state: State
    @NSManaged var body: String
    @NSManaged var title: String
    @NSManaged var reminder: Reminder?
    @NSManaged var updatedDate: NSDate
    @NSManaged var creationDate: NSDate
    
    convenience init(title: String, body: String, insertIntoManagedObjectContext context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName(Note.entityName(), inManagedObjectContext: context)!
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        self.title = title
        self.body = body
        self.state = .Normal
    }
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        setPrimitiveValue(NSDate(), forKey: "creationDate")
        setPrimitiveValue(NSDate(), forKey: "updatedDate")
    }
    
    var shareableString: String {
        if title.isEmpty {
            return body
        } else if body.isEmpty {
            return title
        } else {
            return String(format: "%@ \n\n %@", title, body)
        }
    }
    
}
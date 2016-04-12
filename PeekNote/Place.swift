//
//  Place.swift
//  PeekNote
//
//  Created by Ahmed Onawale on 4/8/16.
//  Copyright © 2016 Ahmed Onawale. All rights reserved.
//

import Foundation
import CoreData

@objc enum Trigger: Int16 {
    case OnEntry
    case OnExit
    
    func title() -> String {
        switch self {
        case .OnEntry:
            return "When I arrive"
        case .OnExit:
            return "When I leave"
        }
    }
}

class Place: NSManagedObject {
    
    @NSManaged var id: String
    @NSManaged var name: String
    @NSManaged var region: String
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var reminder: Reminder
    @NSManaged var trigger: Trigger
    
    convenience init(_ dictionary: [String: AnyObject], insertIntoManagedObjectContext context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName(Place.entityName(), inManagedObjectContext: context)!
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        id = dictionary["place_id"] as? String ?? ""
        let description = dictionary["description"] as? String ?? ""
        var address = description.characters.split { $0 == "," }.map(String.init)
        name = address.removeAtIndex(0) ?? ""
        region = address.joinWithSeparator("") ?? ""
    }
    
    convenience init(_ placeName: String, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName(Place.entityName(), inManagedObjectContext: context)!
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        id = ""
        name = placeName
        region = ""
    }
    
    class func clone(place: Place, insertIntoManagedObjectContext context: NSManagedObjectContext) -> Place {
        let clone = NSEntityDescription.insertNewObjectForEntityForName(Place.entityName(), inManagedObjectContext: context) as! Place
        clone.id = place.id
        clone.name = place.name
        clone.region = place.region
        clone.trigger = place.trigger
        return clone
    }
    
}
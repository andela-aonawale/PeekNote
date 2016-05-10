//
//  Notification.swift
//  PeekNote
//
//  Created by Ahmed Onawale on 5/1/16.
//  Copyright © 2016 Ahmed Onawale. All rights reserved.
//
//  --------------------------------------------
//
//  Simple extensions to help with managed object context fetch, save and deletion.
//
//  --------------------------------------------
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice,
//  this list of conditions and the following disclaimer.
//
//  * Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
//  THE POSSIBILITY OF SUCH DAMAGE.
//

import Foundation
import UIKit
import CoreLocation

extension UILocalNotification {
    
    static func cancelNotificationForReminder(reminder: Reminder) {
        let objectID = reminder.objectID.URIRepresentation().absoluteString
        guard let notification = UILocalNotification.notificationWithID(objectID) else { return }
        UIApplication.sharedApplication().cancelLocalNotification(notification)
    }
    
    static func notificationWithID(objectID: String) -> UILocalNotification? {
        guard let notifications = UIApplication.sharedApplication().scheduledLocalNotifications else {
            return nil
        }
        for notification in notifications {
            guard let id = notification.userInfo?["objectID"] as? String else { break }
            guard objectID == id else { continue }
            return notification
        }
        return nil
    }
    
    static func scheduleNotificationForReminder(reminder: Reminder) {
        let objectID = reminder.objectID.URIRepresentation().absoluteString
        if let notification = UILocalNotification.notificationWithID(objectID) {
            UIApplication.sharedApplication().cancelLocalNotification(notification)
        }
        let notification = UILocalNotification()
        if let place = reminder.place {
            let coordinate = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
            let region = CLCircularRegion(center: coordinate, radius: 100, identifier: place.id)
            region.notifyOnEntry = place.trigger == .OnEntry
            region.notifyOnExit = place.trigger == .OnExit
            notification.region = region
            notification.regionTriggersOnce = false
        } else {
            notification.fireDate = reminder.date
            notification.timeZone = .defaultTimeZone()
            notification.repeatInterval = reminder.repeats.calendarUnit()
        }
        notification.alertBody = reminder.note.title
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.userInfo = ["objectID": objectID]
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
}
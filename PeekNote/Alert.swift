//
//  Alert.swift
//  PeekNote
//
//  Created by Ahmed Onawale on 4/12/16.
//  Copyright © 2016 Ahmed Onawale. All rights reserved.
//

import Foundation

class Alert {
    static func warn(controller: UIViewController, title: String?, message: String?, confirmTitle: String, confirmAction: ((UIAlertAction) -> Void)?, cancelAction: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let confirmAction = UIAlertAction(title: confirmTitle, style: .Default, handler: confirmAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: cancelAction)
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        controller.presentViewController(alert, animated: true, completion: nil)
    }
}
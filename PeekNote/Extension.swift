//
//  Extension.swift
//  PeekNote
//
//  Created by Ahmed Onawale on 3/20/16.
//  Copyright © 2016 Ahmed Onawale. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension UIViewController {
    var contentViewController: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.topViewController ?? self
        }
        return self
    }
}

extension NSString {
    var isEmpty: Bool {
        return self.length == 0
    }
}
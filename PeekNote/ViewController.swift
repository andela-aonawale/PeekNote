//
//  ViewController.swift
//  PeekNote
//
//  Created by Ahmed Onawale on 5/6/16.
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

extension UIViewController {
    
    func presentViewControllerFormSheet(viewController: UIViewController, completion: (() -> ())?) {
        let navCon = UINavigationController(rootViewController: viewController)
        navCon.modalPresentationStyle = .FormSheet
        presentViewController(navCon, animated: true, completion: completion)
    }
    
    func presentViewController(viewController: UIViewController, barButtonItem: UIBarButtonItem, completion: (() -> ())?) {
        let navCon = UINavigationController(rootViewController: viewController)
        navCon.modalPresentationStyle = .Popover
        let ppc = navCon.popoverPresentationController
        ppc?.barButtonItem = barButtonItem
        presentViewController(navCon, animated: true, completion: completion)
    }
    
    func presentViewController(viewController: UIViewController, sourceView: UIView, completion: (() -> ())?) {
        let navCon = UINavigationController(rootViewController: viewController)
        navCon.modalPresentationStyle = .Popover
        let ppc = navCon.popoverPresentationController
        ppc?.sourceView = sourceView
        presentViewController(navCon, animated: true, completion: completion)
    }
    
    var contentViewController: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.topViewController ?? self
        }
        return self
    }
    
    func dismiss() {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
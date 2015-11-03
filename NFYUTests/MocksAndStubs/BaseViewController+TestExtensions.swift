//
//  BaseViewController+TestExtensions.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 01/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import UIKit
@testable import NFYU

extension BaseViewController {
    
    struct TestExtensionNotifications {
        static let DidAttemptSegue = "TestExtensionNotificationsDidAttemptSegue"
    }
    
    struct TestExtensionNotificationsKeys {
        static let SegueIdentifier = "TestExtensionNotificationsKeysSegueIdentifier"
        static let SegueSender = "TestExtensionNotificationsKeysSegueSender"
    }
    
    override func performSegueWithIdentifier(identifier: String, sender: AnyObject?) {
        var userInfo: [String : AnyObject] = [TestExtensionNotificationsKeys.SegueIdentifier: identifier]
        if let sender = sender {
            userInfo[TestExtensionNotificationsKeys.SegueSender] = sender
        }
        NSNotificationCenter.defaultCenter().postNotificationName(TestExtensionNotifications.DidAttemptSegue, object: self, userInfo: userInfo)
    }
    
}

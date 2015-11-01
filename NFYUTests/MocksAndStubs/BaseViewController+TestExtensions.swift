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
    }
    
    override func performSegueWithIdentifier(identifier: String, sender: AnyObject?) {
        let userInfo = [TestExtensionNotificationsKeys.SegueIdentifier: identifier]
        NSNotificationCenter.defaultCenter().postNotificationName(TestExtensionNotifications.DidAttemptSegue, object: self, userInfo: userInfo)
    }
    
}

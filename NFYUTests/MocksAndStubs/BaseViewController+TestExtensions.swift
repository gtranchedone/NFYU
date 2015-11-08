//
//  BaseViewController+TestExtensions.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 01/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import UIKit
@testable import NFYU

struct TestExtensionNotifications {
    static let DidAttemptSegue = "TestExtensionNotificationsDidAttemptSegue"
    static let DidAttemptPresentingViewController = "TestExtensionNotificationsDidAttemptPresentingViewController"
    static let DidAttemptDismissingViewController = "TestExtensionNotificationsDidAttemptDismissingViewController"
}

struct TestExtensionNotificationsKeys {
    static let SegueSender = "TestExtensionNotificationsKeysSegueSender"
    static let SegueIdentifier = "TestExtensionNotificationsKeysSegueIdentifier"
    static let PresentedViewController = "TestExtensionNotificationsKeysPresentedViewController"
}

extension BaseViewController {
    
    override func performSegueWithIdentifier(identifier: String, sender: AnyObject?) {
        var userInfo: [String : AnyObject] = [TestExtensionNotificationsKeys.SegueIdentifier: identifier]
        if let sender = sender {
            userInfo[TestExtensionNotificationsKeys.SegueSender] = sender
        }
        NSNotificationCenter.defaultCenter().postNotificationName(TestExtensionNotifications.DidAttemptSegue, object: self, userInfo: userInfo)
    }
    
    override func dismissViewControllerAnimated(flag: Bool, completion: (() -> Void)?) {
        NSNotificationCenter.defaultCenter().postNotificationName(TestExtensionNotifications.DidAttemptDismissingViewController, object: self)
    }
    
    override func presentViewController(viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
        let userInfo: [String : UIViewController] = [TestExtensionNotificationsKeys.PresentedViewController: viewControllerToPresent]
        let notificationName = TestExtensionNotifications.DidAttemptPresentingViewController
        NSNotificationCenter.defaultCenter().postNotificationName(notificationName, object: self, userInfo: userInfo)
    }
    
}

// TODO: delete me when BaseTableViewController is subclass of BaseViewController

extension BaseTableViewController {
    
    override func performSegueWithIdentifier(identifier: String, sender: AnyObject?) {
        var userInfo: [String : AnyObject] = [TestExtensionNotificationsKeys.SegueIdentifier: identifier]
        if let sender = sender {
            userInfo[TestExtensionNotificationsKeys.SegueSender] = sender
        }
        NSNotificationCenter.defaultCenter().postNotificationName(TestExtensionNotifications.DidAttemptSegue, object: self, userInfo: userInfo)
    }
    
    override func dismissViewControllerAnimated(flag: Bool, completion: (() -> Void)?) {
        NSNotificationCenter.defaultCenter().postNotificationName(TestExtensionNotifications.DidAttemptDismissingViewController, object: self)
    }
    
    override func presentViewController(viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
        let userInfo: [String : UIViewController] = [TestExtensionNotificationsKeys.PresentedViewController: viewControllerToPresent]
        let notificationName = TestExtensionNotifications.DidAttemptPresentingViewController
        NSNotificationCenter.defaultCenter().postNotificationName(notificationName, object: self, userInfo: userInfo)
    }
    
}

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
    
    override open func performSegue(withIdentifier identifier: String, sender: Any?) {
        var userInfo: [String : AnyObject] = [TestExtensionNotificationsKeys.SegueIdentifier: identifier as AnyObject]
        if let sender = sender {
            userInfo[TestExtensionNotificationsKeys.SegueSender] = sender as AnyObject?
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: TestExtensionNotifications.DidAttemptSegue), object: self, userInfo: userInfo)
    }
    
    override open func dismiss(animated flag: Bool, completion: (() -> Void)?) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: TestExtensionNotifications.DidAttemptDismissingViewController), object: self)
    }
    
    override open func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
        let userInfo: [String : UIViewController] = [TestExtensionNotificationsKeys.PresentedViewController: viewControllerToPresent]
        let notificationName = TestExtensionNotifications.DidAttemptPresentingViewController
        NotificationCenter.default.post(name: Notification.Name(rawValue: notificationName), object: self, userInfo: userInfo)
    }
    
}

// TODO: delete me when BaseTableViewController is subclass of BaseViewController

extension BaseTableViewController {
    
    override open func performSegue(withIdentifier identifier: String, sender: Any?) {
        var userInfo: [String : AnyObject] = [TestExtensionNotificationsKeys.SegueIdentifier: identifier as AnyObject]
        if let sender = sender {
            userInfo[TestExtensionNotificationsKeys.SegueSender] = sender as AnyObject?
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: TestExtensionNotifications.DidAttemptSegue), object: self, userInfo: userInfo)
    }
    
    override open func dismiss(animated flag: Bool, completion: (() -> Void)?) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: TestExtensionNotifications.DidAttemptDismissingViewController), object: self)
    }
    
    override open func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
        let userInfo: [String : UIViewController] = [TestExtensionNotificationsKeys.PresentedViewController: viewControllerToPresent]
        let notificationName = TestExtensionNotifications.DidAttemptPresentingViewController
        NotificationCenter.default.post(name: Notification.Name(rawValue: notificationName), object: self, userInfo: userInfo)
    }
    
}

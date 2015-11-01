//
//  MockNotificationObserver.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 01/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import Foundation

class MockNotificationObserver {
    
    private struct ExpeptionNames {
        static let DidReceiveInappropriateNotification = "com.gtranchedone.tests.MockNotificationObserver.DidReceivedInappropriateNotification"
    }
    
    private let notificationName: String
    private let needsCrashingIfReceiveNotification: Bool
    private(set) var didReceiveNotification: Bool = false
    
    init(notificationName: String, sender: AnyObject?, crashIfReceived: Bool = false) {
        self.notificationName = notificationName
        needsCrashingIfReceiveNotification = crashIfReceived
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receiveNotification", name: notificationName, object: sender)
    }
    
    func receiveNotification() {
        didReceiveNotification = true
    }
    
    func verify() {
        if didReceiveNotification && needsCrashingIfReceiveNotification {
            let exception = NSException(name: ExpeptionNames.DidReceiveInappropriateNotification, reason: "Did receive \(notificationName)", userInfo: nil)
            exception.raise()
        }
    }
    
}
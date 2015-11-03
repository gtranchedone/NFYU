//
//  MockNotificationObserver.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 01/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import Foundation

class MockNotificationObserver: NSObject {
    
    private struct ExpeptionNames {
        static let DidReceiveInappropriateNotification = "com.gtranchedone.tests.MockNotificationObserver.DidReceivedInappropriateNotification"
    }
    
    private let notificationName: String
    private(set) var didReceiveNotification: Bool = false
    
    init(notificationName: String, sender: AnyObject?) {
        self.notificationName = notificationName
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receiveNotification", name: notificationName, object: sender)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func receiveNotification() {
        didReceiveNotification = true
    }
    
}
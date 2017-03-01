//
//  MockNotificationObserver.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 01/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import Foundation

class MockNotificationObserver: NSObject {
    
    fileprivate struct ExpeptionNames {
        static let DidReceiveInappropriateNotification = "com.gtranchedone.tests.MockNotificationObserver.DidReceivedInappropriateNotification"
    }
    
    fileprivate let notificationName: String
    fileprivate(set) var didReceiveNotification: Bool = false
    
    init(notificationName: String, sender: AnyObject?) {
        self.notificationName = notificationName
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(MockNotificationObserver.receiveNotification), name: NSNotification.Name(rawValue: notificationName), object: sender)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func receiveNotification() {
        didReceiveNotification = true
    }
    
}

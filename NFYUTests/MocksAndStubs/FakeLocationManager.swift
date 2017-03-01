//
//  FakeLocationManager.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 02/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import Foundation
import CoreLocation
@testable import NFYU

class FakeUserLocationManager: UserLocationManager {
    
    private(set) var didRequestPermissions = false
    private(set) var didRequestCurrentLocation = false
    
    var allowUseOfLocationServices = true
    var shouldCallCompletionBlock = true
    var stubDidRequestPermissions = true
    var stubLocation: CLLocation?
    var stubError: NSError?
    
    var locationServicesEnabled: Bool {
        get { return allowUseOfLocationServices }
    }
    
    var didRequestAuthorization: Bool {
        get { return didRequestPermissions }
    }
    
    @discardableResult func requestUserAuthorizationForUsingLocationServices(_ completionBlock: @escaping () -> ()) -> Bool {
        didRequestPermissions = stubDidRequestPermissions
        completionBlock()
        return stubDidRequestPermissions
    }
    
    @discardableResult func requestCurrentLocation(_ completionBlock: @escaping (NSError?, CLLocation?) -> ()) {
        didRequestCurrentLocation = true
        if shouldCallCompletionBlock {
            completionBlock(stubError, stubLocation)
        }
    }
    
}

class FakeLocationManager: CLLocationManager {
    
    static var stubAuthorizationStatus: CLAuthorizationStatus = .notDetermined
    var didRequestAuthorizationForInUse = false
    var didRequestLocation = false
    
    override class func authorizationStatus() -> CLAuthorizationStatus {
        return stubAuthorizationStatus
    }
    
    override func requestLocation() {
        didRequestLocation = true
    }
    
    override func requestWhenInUseAuthorization() {
        didRequestAuthorizationForInUse = true
    }
    
}

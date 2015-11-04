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

class FakeLocationFinder: LocationFinder {
    
    private(set) var didRequestCurrentLocation = false
    
    var allowUseOfLocationServices = true
    var shouldCallCompletionBlock = true
    var stubLocation: CLLocation?
    var stubError: NSError?
    
    func locationServicesEnabled() -> Bool {
        return allowUseOfLocationServices
    }
    
    func requestCurrentLocation(completionBlock: (NSError?, CLLocation?) -> ()) {
        didRequestCurrentLocation = true
        if shouldCallCompletionBlock {
            completionBlock(stubError, stubLocation)
        }
    }
    
}

class FakeLocationManager: CLLocationManager {
    
    static var stubAuthorizationStatus: CLAuthorizationStatus = .NotDetermined
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

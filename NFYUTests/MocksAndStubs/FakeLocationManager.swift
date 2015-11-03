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
    
    var allowUseOfLocationServices = true
    var didRequestCurrentLocation = false
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
    var didStartUpdatingLocation = false
    var didStopUpdatingLocation = false
    
    override class func authorizationStatus() -> CLAuthorizationStatus {
        return stubAuthorizationStatus
    }
    
    override func startUpdatingLocation() {
        didStartUpdatingLocation = true
    }
    
    override func stopUpdatingLocation() {
        didStopUpdatingLocation = true
    }
    
    override func requestWhenInUseAuthorization() {
        didRequestAuthorizationForInUse = true
    }
    
}

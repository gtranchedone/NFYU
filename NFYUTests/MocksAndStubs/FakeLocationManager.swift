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

class FakeLocationManager: LocationManager {
    
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

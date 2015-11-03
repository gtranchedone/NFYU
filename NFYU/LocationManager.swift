//
//  LocationManager.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 02/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationManager : AnyObject {
    
    func locationServicesEnabled() -> Bool
    func requestCurrentLocation(completionBlock: (NSError?, CLLocation?) -> ())
    
}

class SystemLocationManager : NSObject, LocationManager, CLLocationManagerDelegate {
    
    let locationManager: CLLocationManager
    
    init(locationManager: CLLocationManager? = nil) {
        self.locationManager = locationManager ?? CLLocationManager()
    }
    
    // MARK: - LocationManager
    
    func locationServicesEnabled() -> Bool {
        return false // CLLocationManager.locationServicesEnabled()
    }
    
    func requestCurrentLocation(completionBlock: (NSError?, CLLocation?) -> ()) {
        // TODO: implement me
    }
    
    // MARK: - CLLocationManagerDelegate
    
}

//
// Created by Gianluca Tranchedone on 06/11/2015.
// Copyright (c) 2015 Gianluca Tranchedone. All rights reserved.
//

import Foundation
import CoreLocation

class SystemUserLocationManager: NSObject {
    
    fileprivate let locationManager: CLLocationManager
    fileprivate var completionBlock: ((NSError?, CLLocation?) -> ())?
    fileprivate var permissionsCompletionBlock: (() -> ())?
    
    init(locationManager: CLLocationManager? = nil) {
        self.locationManager = locationManager ?? CLLocationManager()
        super.init()
        self.locationManager.delegate = self
    }
    
}

extension SystemUserLocationManager: UserLocationManager {
    
    fileprivate func authorizationStatus() -> CLAuthorizationStatus {
        return type(of: locationManager).authorizationStatus()
    }
    
    var locationServicesEnabled: Bool {
        return authorizationStatus() == .authorizedWhenInUse
    }
    
    var didRequestAuthorization: Bool {
        return authorizationStatus() != .notDetermined
    }
    
    func requestUserAuthorizationForUsingLocationServices(_ completionBlock: @escaping () -> ()) -> Bool {
        guard authorizationStatus() == .notDetermined else { return false }
        self.permissionsCompletionBlock = completionBlock
        locationManager.requestWhenInUseAuthorization()
        return true
    }
    
    func requestCurrentLocation(_ completionBlock: @escaping (NSError?, CLLocation?) -> ()) {
        self.completionBlock = completionBlock
        let authorizationStatus = self.authorizationStatus()
        if authorizationStatus == .notDetermined {
            let _ = requestUserAuthorizationForUsingLocationServices() { [weak self] in
                self?.requestCurrentLocation(completionBlock)
            }
        }
        else if authorizationStatus != .authorizedWhenInUse {
            let userInfo = [NSLocalizedDescriptionKey: NSLocalizedString("USE_OF_LOCATION_SERVICES_NOT_AUTHORIZED", comment: "")]
            let error = NSError(domain: UserLocationManagerErrorDomain, code: 0, userInfo: userInfo)
            completionBlock(error, nil)
            self.completionBlock = nil
        }
        else {
            locationManager.requestLocation()
        }
    }
    
}

extension SystemUserLocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if let completionBlock = permissionsCompletionBlock {
            completionBlock()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        completionBlock?(nil, locations.first)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // bacause the description of the default error isn't great...
        let userInfo = [NSLocalizedDescriptionKey: NSLocalizedString("CANNOT_FIND_CURRENT_LOCATION", comment: "")]
        let finalError = NSError(domain: error._domain, code: error._code, userInfo: userInfo)
        completionBlock?(finalError, nil)
    }
    
}

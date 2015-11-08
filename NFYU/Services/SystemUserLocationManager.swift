//
// Created by Gianluca Tranchedone on 06/11/2015.
// Copyright (c) 2015 Gianluca Tranchedone. All rights reserved.
//

import Foundation
import CoreLocation

class SystemUserLocationManager: NSObject, UserLocationManager, CLLocationManagerDelegate {

    private let locationManager: CLLocationManager
    private var completionBlock: ((NSError?, CLLocation?) -> ())?

    init(locationManager: CLLocationManager? = nil) {
        self.locationManager = locationManager ?? CLLocationManager()
        super.init()
        self.locationManager.delegate = self
    }

    // MARK: - LocationManager

    private func authorizationStatus() -> CLAuthorizationStatus {
        return locationManager.dynamicType.authorizationStatus()
    }
    
    var locationServicesEnabled: Bool {
        get {
            return authorizationStatus() == .AuthorizedWhenInUse || authorizationStatus() == .NotDetermined
        }
    }
    
    func requestUserAuthorizationForUsingLocationServices() -> Bool {
        guard authorizationStatus() == .NotDetermined else { return false }
        locationManager.requestWhenInUseAuthorization()
        return true
    }

    func requestCurrentLocation(completionBlock: (NSError?, CLLocation?) -> ()) {
        self.completionBlock = completionBlock
        let authorizationStatus = self.authorizationStatus()
        if authorizationStatus == .NotDetermined {
            requestUserAuthorizationForUsingLocationServices()
        }
        else if authorizationStatus != .AuthorizedWhenInUse {
            let userInfo = [NSLocalizedDescriptionKey: NSLocalizedString("USE_OF_LOCATION_SERVICES_NOT_AUTHORIZED", comment: "")]
            let error = NSError(domain: UserLocationManagerErrorDomain, code: 0, userInfo: userInfo)
            completionBlock(error, nil)
            self.completionBlock = nil
        }
        else {
            locationManager.requestLocation()
        }
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if let completionBlock = completionBlock {
            requestCurrentLocation(completionBlock)
        }
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let completionBlock = completionBlock {
            completionBlock(nil, locations.first)
        }
    }

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        if let completionBlock = completionBlock {
            // bacause the description of the default error isn't great...
            let userInfo = [NSLocalizedDescriptionKey: NSLocalizedString("CANNOT_FIND_CURRENT_LOCATION", comment: "")]
            let finalError = NSError(domain: error.domain, code: error.code, userInfo: userInfo)
            completionBlock(finalError, nil)
        }
    }

}

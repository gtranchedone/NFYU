//
//  FakeGeocoder.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 04/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import Foundation
import CoreLocation

class FakeGeocoder: CLGeocoder {
    
    var canCallCompletionHandler = true
    var stubPlacemarks: [CLPlacemark]?
    var stubError: NSError?
    
    private(set) var lastGeocodedString: String?
    private(set) var didCancelGeocode = false
    private(set) var _geocoding = false
    
    override var geocoding: Bool { get { return _geocoding } }
    
    override func geocodeAddressString(addressString: String, completionHandler: CLGeocodeCompletionHandler) {
        _geocoding = true
        lastGeocodedString = addressString
        if canCallCompletionHandler {
            _geocoding = false
            completionHandler(stubPlacemarks, stubError)
        }
    }
    
    override func cancelGeocode() {
        didCancelGeocode = true
        lastGeocodedString = nil
    }
    
}

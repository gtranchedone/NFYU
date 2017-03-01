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
    
    override var isGeocoding: Bool {
        return _geocoding
    }
    
    override func geocodeAddressString(_ addressString: String, completionHandler: @escaping CLGeocodeCompletionHandler) {
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

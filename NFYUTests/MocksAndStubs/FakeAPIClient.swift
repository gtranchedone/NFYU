//
//  FakeAPIClient.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 05/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import Foundation
import CoreLocation
@testable import NFYU

class FakeAPIClient: APIClient {
    
    private(set) var lastRequestCoordinate: CLLocationCoordinate2D?
    
    func fetchForecastsForLocationWithCoordinate(coordinate: CLLocationCoordinate2D, completionBlock: (NSError?, [Forecast]?, LocationInfo?) -> ()) {
        lastRequestCoordinate = coordinate
    }
    
}

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

class FakeRequestSerializer: APIClientRequestSerializer {
    
    func buildURLRequestToFetchForecastsForLocationWithCoordinate(coordinate: CLLocationCoordinate2D) -> NSURLRequest {
        return NSURLRequest(URL: NSURL(string: "http://google.com")!)
    }
    
}

class FakeResponseSerializer: APIClientResponseSerializer {
    
    func parseForecastsAPIResponseData(data: NSData) -> (NSError?, [Forecast]?, LocationInfo?) {
        return (nil, nil, nil)
    }
    
}

class FakeAPIClient: APIClient {
    
    private(set) var lastRequestCoordinate: CLLocationCoordinate2D?
    private(set) var requestedCoordinates: [CLLocationCoordinate2D] = []
    
    var stubError: NSError?
    var stubForecasts: [Forecast]?
    var stubLocationInfo: LocationInfo?
    
    convenience init() {
        self.init(requestSerializer: FakeRequestSerializer(), responseSerializer: FakeResponseSerializer())
    }
    
    override func fetchForecastsForLocationWithCoordinate(coordinate: CLLocationCoordinate2D, completionBlock: (NSError?, [Forecast]?, LocationInfo?) -> ()) {
        lastRequestCoordinate = coordinate
        requestedCoordinates.append(coordinate)
        completionBlock(stubError, stubForecasts, stubLocationInfo)
    }
    
}

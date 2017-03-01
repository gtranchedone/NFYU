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

class FakeRequestSerializer: APIRequestSerializer {
    
    var stubURLString = "http://google.com"
    
    func buildURLRequestToFetchForecastsForLocationWithCoordinate(_ coordinate: CLLocationCoordinate2D) -> URLRequest {
        return URLRequest(url: URL(string: stubURLString)!)
    }
    
}

class FakeResponseSerializer: APIResponseSerializer {
    
    var stubError: NSError?
    var stubForecasts: [Forecast]?
    var stubLocationInfo: LocationInfo?
    
    func parseForecastsAPIResponseData(_ data: Data) -> SerializedAPIResponse {
        return (stubError, stubForecasts, stubLocationInfo)
    }
    
}

class FakeAPIClient: APIClient {
    
    fileprivate(set) var lastRequestCoordinate: CLLocationCoordinate2D?
    fileprivate(set) var requestedCoordinates: [CLLocationCoordinate2D] = []
    
    var stubError: NSError?
    var stubForecasts: [Forecast]?
    var stubLocationInfo: LocationInfo?
    
    convenience init() {
        self.init(requestSerializer: FakeRequestSerializer(), responseSerializer: FakeResponseSerializer())
    }
    
    override func fetchForecastsForLocationWithCoordinate(_ coordinate: CLLocationCoordinate2D, completionBlock: @escaping (NSError?, [Forecast]?, LocationInfo?) -> ()) {
        lastRequestCoordinate = coordinate
        requestedCoordinates.append(coordinate)
        completionBlock(stubError, stubForecasts, stubLocationInfo)
    }
    
}

//
//  APIClient.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 05/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import Foundation
import CoreLocation

struct LocationInfo {
    
    let cityID: String
    let cityName: String
    let cityCountry: String
    
}

protocol APIClientRequestSerializer {
    
    func buildURLRequestToFetchForecastsForLocationWithCoordinate(coordinate: CLLocationCoordinate2D) -> NSURLRequest
    
}

protocol APIClientResponseSerializer {
    
    func parseForecastsAPIResponseData(data: NSData) -> (NSError?, [Forecast]?, LocationInfo?)
    
}

class APIClient: AnyObject {
    
    let requestSerializer: APIClientRequestSerializer
    let responseSerializer: APIClientResponseSerializer
    
    init(requestSerializer: APIClientRequestSerializer, responseSerializer: APIClientResponseSerializer) {
        self.requestSerializer = requestSerializer
        self.responseSerializer = responseSerializer
    }
    
    func fetchForecastsForLocationWithCoordinate(coordinate: CLLocationCoordinate2D, completionBlock: (NSError?, [Forecast]?, LocationInfo?) -> ()) {
        // TODO: implement me
    }
    
}

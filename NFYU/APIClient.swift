//
//  APIClient.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 05/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import Foundation
import CoreLocation

struct LocationInfo: Equatable {
    
    let cityID: String
    let cityName: String
    let cityCountry: String
    
}

func ==(lhs: LocationInfo, rhs: LocationInfo) -> Bool {
    return lhs.cityID == rhs.cityID
}

protocol APIRequestSerializer {
    
    func buildURLRequestToFetchForecastsForLocationWithCoordinate(coordinate: CLLocationCoordinate2D) -> NSURLRequest
    
}

typealias SerializedAPIResponse = (error: NSError?, forecasts: [Forecast]?, locationInfo: LocationInfo?)

protocol APIResponseSerializer {
    
    func parseForecastsAPIResponseData(data: NSData) -> SerializedAPIResponse
    
}

class APIClient: AnyObject {
    
    var session = NSURLSession.sharedSession()
    let requestSerializer: APIRequestSerializer
    let responseSerializer: APIResponseSerializer
    
    init(requestSerializer: APIRequestSerializer, responseSerializer: APIResponseSerializer) {
        self.requestSerializer = requestSerializer
        self.responseSerializer = responseSerializer
    }
    
    func fetchForecastsForLocationWithCoordinate(coordinate: CLLocationCoordinate2D, completionBlock: (NSError?, [Forecast]?, LocationInfo?) -> ()) {
        let request = requestSerializer.buildURLRequestToFetchForecastsForLocationWithCoordinate(coordinate)
        let task = session.dataTaskWithRequest(request) { [weak self] (data, response, error) -> Void in
            var locationInfo: LocationInfo?
            var forecasts: [Forecast]?
            var finalError = error
            if let data = data {
                let parsedResponse = self?.responseSerializer.parseForecastsAPIResponseData(data)
                locationInfo = parsedResponse?.locationInfo
                forecasts = parsedResponse?.forecasts
                finalError = parsedResponse?.error
            }
            completionBlock(finalError, forecasts, locationInfo)
        }
        logRequest(request)
        task.resume()
    }
    
    private func logRequest(request: NSURLRequest) {
        debugPrint("- Performing \(request.HTTPMethod!) request to \(request.URL!)")
    }
    
}

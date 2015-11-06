//
//  APIClient.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 05/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import Foundation
import CoreLocation

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
    
    // The completion block is always called on the main queue
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
            self?.logResponse(response, error: finalError, forecasts: forecasts, locationInfo: locationInfo)
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                completionBlock(finalError, forecasts, locationInfo)
            })
        }
        logRequest(request)
        task.resume()
    }
    
    private func logRequest(request: NSURLRequest) {
        debugPrint("Performing \(request.HTTPMethod!) request to \(request.URL!)", terminator: "\n\n")
    }
    
    private func logResponse(response: NSURLResponse?, error: NSError?, forecasts: [Forecast]?, locationInfo: LocationInfo?) {
        debugPrint("Received response for URL \(response?.URL!) with error -> \(error)\nlocationInfo -> \(locationInfo)\nforecasts -> \(forecasts)", terminator: "\n\n")
    }
    
}

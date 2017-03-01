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
    
    func buildURLRequestToFetchForecastsForLocationWithCoordinate(_ coordinate: CLLocationCoordinate2D) -> URLRequest
    
}

typealias SerializedAPIResponse = (error: NSError?, forecasts: [Forecast]?, locationInfo: LocationInfo?)

protocol APIResponseSerializer {
    
    func parseForecastsAPIResponseData(_ data: Data) -> SerializedAPIResponse
    
}

class APIClient: AnyObject {
    
    var session = URLSession.shared
    let requestSerializer: APIRequestSerializer
    let responseSerializer: APIResponseSerializer
    
    init(requestSerializer: APIRequestSerializer, responseSerializer: APIResponseSerializer) {
        self.requestSerializer = requestSerializer
        self.responseSerializer = responseSerializer
    }
    
    // The completion block is always called on the main queue
    func fetchForecastsForLocationWithCoordinate(_ coordinate: CLLocationCoordinate2D, completionBlock: @escaping (NSError?, [Forecast]?, LocationInfo?) -> ()) {
        let request = requestSerializer.buildURLRequestToFetchForecastsForLocationWithCoordinate(coordinate)
        let task = session.dataTask(with: request, completionHandler: { [weak self] (data, response, error) -> Void in
            var locationInfo: LocationInfo?
            var forecasts: [Forecast]?
            var finalError = error
            if let data = data {
                let parsedResponse = self?.responseSerializer.parseForecastsAPIResponseData(data)
                locationInfo = parsedResponse?.locationInfo
                forecasts = parsedResponse?.forecasts
                finalError = parsedResponse?.error
            }
            self?.logResponse(response, error: finalError as NSError?, forecasts: forecasts, locationInfo: locationInfo)
            OperationQueue.main.addOperation({ () -> Void in
                completionBlock(finalError as NSError?, forecasts, locationInfo)
            })
        }) 
        logRequest(request)
        task.resume()
    }
    
    fileprivate func logRequest(_ request: URLRequest) {
        // use print instead of debugPrint for pretty printing
        print("Performing \(request.httpMethod!) request to \(request.url!)", terminator: "\n\n")
    }
    
    fileprivate func logResponse(_ response: URLResponse?, error: NSError?, forecasts: [Forecast]?, locationInfo: LocationInfo?) {
        // use print instead of debugPrint for pretty printing
        print("Received response for URL \(response?.url) with error -> \(error)\nlocationInfo -> \(locationInfo)\nforecasts -> \(forecasts)", terminator: "\n\n")
    }
    
}

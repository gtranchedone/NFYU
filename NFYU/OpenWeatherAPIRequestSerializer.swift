//
//  OpenWeatherAPIClient.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 05/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import Foundation
import CoreLocation

let kOpenWeatherMapAPIKeyEnvironmentVariable = "com.gtranchedone.openWeatherAPIKey"

class OpenWeatherAPIClientRequestSerializer: APIRequestSerializer {

    struct APIConstants {
        static let BaseOpenWeatherMapAPIURL = "http://api.openweathermap.org/data/2.5/"
        static let ForecastEndpoint = "forecast"
    }
    
    func buildURLRequestToFetchForecastsForLocationWithCoordinate(coordinate: CLLocationCoordinate2D) -> NSURLRequest {
        let endpoint = APIConstants.ForecastEndpoint
        let baseURLString = APIConstants.BaseOpenWeatherMapAPIURL
        let applicationID = NSProcessInfo.processInfo().environment[kOpenWeatherMapAPIKeyEnvironmentVariable]!
        let basicURLRequestString = "\(baseURLString)\(endpoint)?lat=\(coordinate.latitude)&lon=\(coordinate.longitude)"
        let requestCustomizationFields = "&units=metric&appid=\(applicationID)"
        let requestURLString = "\(basicURLRequestString)\(requestCustomizationFields)"
        return NSURLRequest(URL: NSURL(string: requestURLString)!)
    }
    
}

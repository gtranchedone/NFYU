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
    
    func buildURLRequestToFetchForecastsForLocationWithCoordinate(_ coordinate: CLLocationCoordinate2D) -> URLRequest {
        let endpoint = APIConstants.ForecastEndpoint
        let baseURLString = APIConstants.BaseOpenWeatherMapAPIURL
        let applicationID = ProcessInfo.processInfo.environment[kOpenWeatherMapAPIKeyEnvironmentVariable]!
        let basicURLRequestString = "\(baseURLString)\(endpoint)?lat=\(coordinate.latitude)&lon=\(coordinate.longitude)"
        let requestCustomizationFields = "&units=metric&appid=\(applicationID)"
        let requestURLString = "\(basicURLRequestString)\(requestCustomizationFields)"
        return URLRequest(url: URL(string: requestURLString)!)
    }
    
}

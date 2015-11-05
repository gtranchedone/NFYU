//
//  OpenWeatherAPIClient.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 05/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import Foundation
import CoreLocation

class OpenWeatherAPIClientRequestSerializer: APIClientRequestSerializer {

    func buildURLRequestToFetchForecastsForLocationWithCoordinate(coordinate: CLLocationCoordinate2D) -> NSURLRequest {
        // TODO: implement me
        return NSURLRequest(URL: NSURL())
    }
    
}

//
//  OpenWeatherAPIClientResponseSerializer.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 05/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import Foundation

class OpenWeatherAPIClientResponseSerializer: NSObject, APIResponseSerializer {

    func parseForecastsAPIResponseData(data: NSData) -> SerializedAPIResponse {
        return (nil, nil, nil)
    }
    
}

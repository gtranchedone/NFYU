//
//  Forecast.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 05/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import Foundation

enum WeatherCondition {
    case Clear
    case FewClouds, Clouds
    case Rain, ShowerRain, Thunderstorm
    case Snow
    case Mist
    case Wind, Hurricane
    case Danger
    
    // TODO: add method to get icon
    // TODO: add method to get description
}

struct Forecast: Equatable, CustomStringConvertible {
    
    typealias CelsiusDegrees = Int
    
    let date: NSDate
    let cityID: String
    let weather: WeatherCondition
    let minTemperature: CelsiusDegrees
    let maxTemperature: CelsiusDegrees
    let currentTemperature: CelsiusDegrees
    
    // MARK: CustomDebugStringConvertible
    var description: String {
        get {
            // use dictionary description for pretty printing
            let dictionaryValue: [String : Any] = ["date": date,
                                                   "cityID": cityID,
                                                   "weather": weather,
                                                   "minTemp": minTemperature,
                                                   "maxTemp": maxTemperature,
                                                   "currentTemp": currentTemperature]
            return dictionaryValue.description
        }
    }
    
}

func ==(lhs: Forecast, rhs: Forecast) -> Bool {
    return lhs.cityID == rhs.cityID && lhs.date == rhs.date
}

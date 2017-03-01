//
//  Forecast.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 05/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import Foundation

// Since weather conditions format may differ between weather forecast services, let's standardize it in our Domain
enum WeatherCondition: String {
    case Clear = "WEATHER_CONDITION_CLEAR"
    case FewClouds = "WEATHER_CONDITION_FEW_CLOUDS", Clouds = "WEATHER_CONDITION_CLOUDS"
    case Rain = "WEATHER_CONDITION_RAIN", ShowerRain = "WEATHER_CONDITION_SHOWER_RAIN", Thunderstorm = "WEATHER_CONDITION_THUNDERSTORM"
    case Snow = "WEATHER_CONDITION_SNOW"
    case Mist = "WEATHER_CONDITION_MIST"
    case Wind = "WEATHER_CONDITION_WIND", Hurricane = "WEATHER_CONDITION_HURRICANE"
    case Danger = "WEATHER_CONDITION_DANGER"
    
    var localizedDescription: String {
        get { return NSLocalizedString(self.rawValue, comment: "") }
    }
    
    // TODO: add method to get icon
}

typealias CelsiusDegrees = Int
typealias FahrenheitDegrees = Int

extension CelsiusDegrees {
    
    func toFahrenheit() -> FahrenheitDegrees {
        return FahrenheitDegrees(round((Double(self) * (9.0 / 5.0)) + 32))
    }
    
}

//extension FahrenheitDegrees {
//    
//    func toCelsius() -> CelsiusDegrees {
//        return CelsiusDegrees(round(Double(self - 32) * (5.0 / 9.0)))
//    }
//    
//}

struct Forecast: Equatable, CustomStringConvertible {
    
    let date: Date
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

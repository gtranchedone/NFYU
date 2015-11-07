//
//  OpenWeatherAPIClientResponseSerializer.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 05/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import Foundation

let kOpenWeatherAPIClientResponseSerializerErrorDomain = "OpenWeatherAPIClientResponseSerializerErrorDomain"

class OpenWeatherAPIClientResponseSerializer: NSObject, APIResponseSerializer {
    
    enum ErrorCodes: Int {
        case OK = 200
        case UnacceptableResponse = 406
    }
    
    enum ResponseKeys: String {
        case StatusCode = "cod"
        case LocationInfo = "city"
        case ForecastsData = "list"
        case ErrorMessage = "message"
    }
    
    enum LocationInfoKeys: String {
        case ID = "id"
        case Name = "name"
        case Country = "country"
    }
    
    /*
    "dt": 1446573600,
    "main": {
    "temp": 11.93,
    "temp_min": 11.93,
    "temp_max": 12.86,
    "pressure": 1017.32,
    "sea_level": 1027.41,
    "grnd_level": 1017.32,
    "humidity": 97,
    "temp_kf": -0.93
    },
    "weather": [
    {
    "id": 500,
    "main": "Rain",
    "description": "light rain",
    "icon": "10n"
    }
    ],
    */
    enum ForecastInfoKeys: String {
        case Date = "dt"
        case MainInfo = "main"
        case CurrentTemperature = "temp"
        case MinTemperature = "temp_min"
        case MaxTemperature = "temp_max"
        case WeatherInfo = "weather"
        case WeatherCode = "id"
    }
    
    func parseForecastsAPIResponseData(data: NSData) -> SerializedAPIResponse {
        do {
            let parsedData = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? [String : AnyObject]
            guard parsedData != nil else { return (errorForUnexpectedResponseFormat(), nil, nil) }
            
            let errorCode = parsedData![ResponseKeys.StatusCode.rawValue] as? String
            guard errorCode != nil else { return (errorForUnexpectedResponseData(), nil, nil) }
            
            guard Int(errorCode!) == ErrorCodes.OK.rawValue else {
                return (errorForAPIErrorWithInfo(parsedData!, errorCode: errorCode!), nil, nil)
            }
            
            let locationInfo = parseLocationInfoInResponse(parsedData!)
            let forecasts = parseForcastsInResponse(parsedData!, locationInfo: locationInfo)
            return (nil, forecasts, locationInfo)
        }
        catch {
            return (error as NSError, nil, nil)
        }
    }
    
    private func parseLocationInfoInResponse(response: [String : AnyObject]) -> LocationInfo? {
        let locationInfoDictionary = response[ResponseKeys.LocationInfo.rawValue]
        guard locationInfoDictionary != nil else { return nil }
        // it's OK to crash if the expected info isn't there for first MVP
        let cityID = locationInfoDictionary![LocationInfoKeys.ID.rawValue] as! Int
        let cityName = locationInfoDictionary![LocationInfoKeys.Name.rawValue] as! String
        let cityCountry = locationInfoDictionary![LocationInfoKeys.Country.rawValue] as! String
        return LocationInfo(id: String(cityID), name: cityName, country: cityCountry)
    }
    
    private func parseForcastsInResponse(response: [String : AnyObject], locationInfo: LocationInfo?) -> [Forecast]? {
        let forecastsData = response[ResponseKeys.ForecastsData.rawValue] as? [[String : AnyObject]]
        guard forecastsData != nil else { return nil }
        return forecastsData!.map { (forecastDictionary) -> Forecast in
            return forecastFromDictionary(forecastDictionary, cityID: locationInfo?.id ?? "")
        }
    }
    
    private func forecastFromDictionary(dictionary: [String : AnyObject], cityID: String) -> Forecast {
        // it's OK to crash if the expected info isn't there for first MVP
        let unixTimestamp = dictionary[ForecastInfoKeys.Date.rawValue] as! NSTimeInterval
        let date = NSDate(timeIntervalSince1970: unixTimestamp)
        let mainSection = dictionary[ForecastInfoKeys.MainInfo.rawValue] as! [String : Float]
        let minTemperature = Int(round(mainSection[ForecastInfoKeys.MinTemperature.rawValue]!))
        let maxTemperature = Int(round(mainSection[ForecastInfoKeys.MaxTemperature.rawValue]!))
        let currentTemperature = Int(round(mainSection[ForecastInfoKeys.CurrentTemperature.rawValue]!))
        let weatherSection = dictionary[ForecastInfoKeys.WeatherInfo.rawValue] as! [[String : AnyObject]]
        let weatherCode = weatherSection.first?[ForecastInfoKeys.WeatherCode.rawValue] as! Int
        return Forecast(date: date,
                        cityID: cityID,
                        weather: weatherConditionFromCode(weatherCode),
                        minTemperature: minTemperature,
                        maxTemperature: maxTemperature,
                        currentTemperature: currentTemperature)
    }
    
    private func weatherConditionFromCode(weatherCode: Int) -> WeatherCondition {
        // TODO: remove this magic numbers
        if (weatherCode >= 900 && weatherCode < 910) || weatherCode >= 958 {
            return .Danger
        }
        else if weatherCode >= 910 && weatherCode < 958 {
            return .Wind
        }
        else if weatherCode > 801 {
            return .Clouds
        }
        else if weatherCode == 801 {
            return .FewClouds
        }
        else if weatherCode == 800 {
            return .Clear
        }
        else if weatherCode >= 700 {
            return .Mist
        }
        else if weatherCode >= 600 {
            return .Snow
        }
        else if weatherCode > 500 {
            return .ShowerRain
        }
        else if weatherCode >= 300 {
            return .Rain
        }
        return .Thunderstorm
    }
    
    private func errorForUnexpectedResponseFormat() -> NSError {
        let userInfo = [NSLocalizedDescriptionKey: "The data couldn’t be read because it isn’t in the expected format."]
        let error = NSError(domain: kOpenWeatherAPIClientResponseSerializerErrorDomain, code: ErrorCodes.UnacceptableResponse.rawValue, userInfo: userInfo)
        return error
    }
    
    private func errorForUnexpectedResponseData() -> NSError {
        let userInfo = [NSLocalizedDescriptionKey: "The data couldn’t be read because it doesn’t contain the expected data."]
        let error = NSError(domain: kOpenWeatherAPIClientResponseSerializerErrorDomain, code: ErrorCodes.UnacceptableResponse.rawValue, userInfo: userInfo)
        return error
    }
    
    private func errorForAPIErrorWithInfo(errorInfo: [String : AnyObject], errorCode: String) -> NSError {
        let message = errorInfo[ResponseKeys.ErrorMessage.rawValue] as! String
        let userInfo = [NSLocalizedDescriptionKey: message]
        let error = NSError(domain: kOpenWeatherAPIClientResponseSerializerErrorDomain, code: Int(errorCode)!, userInfo: userInfo)
        return error
    }
    
}

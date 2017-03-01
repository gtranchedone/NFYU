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
        case ok = 200
        case unacceptableResponse = 406
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
    
    enum ForecastInfoKeys: String {
        case Date = "dt"
        case MainInfo = "main"
        case CurrentTemperature = "temp"
        case MinTemperature = "temp_min"
        case MaxTemperature = "temp_max"
        case WeatherInfo = "weather"
        case WeatherCode = "id"
    }
    
    func parseForecastsAPIResponseData(_ data: Data) -> SerializedAPIResponse {
        do {
            let parsedData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String : AnyObject]
            guard parsedData != nil else { return (errorForUnexpectedResponseFormat(), nil, nil) }
            
            let errorCode = parsedData![ResponseKeys.StatusCode.rawValue] as? String
            guard errorCode != nil else { return (errorForUnexpectedResponseData(), nil, nil) }
            
            guard Int(errorCode!) == ErrorCodes.ok.rawValue else {
                return (errorForAPIErrorWithInfo(parsedData!, errorCode: errorCode!), nil, nil)
            }
            
            let locationInfo = parseLocationInfoInResponse(parsedData!)
            let forecasts = parseForcastsInResponse(parsedData!, locationInfo: locationInfo)
            return (nil, forecasts, locationInfo)
        }
        catch {
            return (error as NSError , nil, nil)
        }
    }
    
    fileprivate func parseLocationInfoInResponse(_ response: [String : AnyObject]) -> LocationInfo? {
        let locationInfoDictionary = response[ResponseKeys.LocationInfo.rawValue]
        guard locationInfoDictionary != nil else { return nil }
        // it's OK to crash if the expected info isn't there for first MVP
        let cityID = locationInfoDictionary![LocationInfoKeys.ID.rawValue] as! Int
        let cityName = locationInfoDictionary![LocationInfoKeys.Name.rawValue] as! String
        let cityCountry = locationInfoDictionary![LocationInfoKeys.Country.rawValue] as! String
        return LocationInfo(id: String(cityID), name: cityName, country: cityCountry)
    }
    
    fileprivate func parseForcastsInResponse(_ response: [String : AnyObject], locationInfo: LocationInfo?) -> [Forecast]? {
        let forecastsData = response[ResponseKeys.ForecastsData.rawValue] as? [[String : AnyObject]]
        guard forecastsData != nil else { return nil }
        return forecastsData!.map { (forecastDictionary) -> Forecast in
            return forecastFromDictionary(forecastDictionary, cityID: locationInfo?.id ?? "")
        }
    }
    
    fileprivate func forecastFromDictionary(_ dictionary: [String : AnyObject], cityID: String) -> Forecast {
        // it's OK to crash if the expected info isn't there for first MVP
        let unixTimestamp = dictionary[ForecastInfoKeys.Date.rawValue] as! TimeInterval
        let date = Date(timeIntervalSince1970: unixTimestamp)
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
    
    fileprivate func weatherConditionFromCode(_ weatherCode: Int) -> WeatherCondition {
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
    
    fileprivate func errorForUnexpectedResponseFormat() -> NSError {
        let userInfo = [NSLocalizedDescriptionKey: "The data couldn’t be read because it isn’t in the expected format."]
        let error = NSError(domain: kOpenWeatherAPIClientResponseSerializerErrorDomain, code: ErrorCodes.unacceptableResponse.rawValue, userInfo: userInfo)
        return error
    }
    
    fileprivate func errorForUnexpectedResponseData() -> NSError {
        let userInfo = [NSLocalizedDescriptionKey: "The data couldn’t be read because it doesn’t contain the expected data."]
        let error = NSError(domain: kOpenWeatherAPIClientResponseSerializerErrorDomain, code: ErrorCodes.unacceptableResponse.rawValue, userInfo: userInfo)
        return error
    }
    
    fileprivate func errorForAPIErrorWithInfo(_ errorInfo: [String : AnyObject], errorCode: String) -> NSError {
        let message = errorInfo[ResponseKeys.ErrorMessage.rawValue] as! String
        let userInfo = [NSLocalizedDescriptionKey: message]
        let error = NSError(domain: kOpenWeatherAPIClientResponseSerializerErrorDomain, code: Int(errorCode)!, userInfo: userInfo)
        return error
    }
    
}

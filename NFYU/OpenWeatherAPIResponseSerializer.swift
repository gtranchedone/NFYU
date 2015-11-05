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
        case ErrorMessage = "message"
    }
    
    enum LocationInfoKeys: String {
        case ID = "id"
        case Name = "name"
        case Country = "country"
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
            
            return (nil, parseForcastsInResponse(parsedData!), parseLocationInfoInResponse(parsedData!))
        }
        catch {
            return (error as NSError, nil, nil)
        }
    }
    
    private func parseLocationInfoInResponse(response: [String : AnyObject]) -> LocationInfo? {
        let locationInfoDictionary = response[ResponseKeys.LocationInfo.rawValue]
        guard locationInfoDictionary != nil else { return nil }
        // it's OK to crash if the expected info isn't there
        let cityID = locationInfoDictionary![LocationInfoKeys.ID.rawValue] as! Int
        let cityName = locationInfoDictionary![LocationInfoKeys.Name.rawValue] as! String
        let cityCountry = locationInfoDictionary![LocationInfoKeys.Country.rawValue] as! String
        return LocationInfo(cityID: String(cityID), cityName: cityName, cityCountry: cityCountry)
    }
    
    private func parseForcastsInResponse(response: [String : AnyObject]) -> [Forecast]? {
        return nil
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

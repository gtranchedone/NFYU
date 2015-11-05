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
    
    enum ResponseKeys: String {
        case StatusCode = "cod"
        case ErrorMessage = "message"
    }
    
    enum ErrorCodes: Int {
        case OK = 200
        case UnacceptableResponse = 406
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
            
            return (nil, nil, nil)
        }
        catch {
            return (error as NSError, nil, nil)
        }
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

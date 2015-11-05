//
//  TestOpenWeatherAPIResponseSerializer.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 05/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import XCTest
@testable import NFYU

class TestOpenWeatherAPIResponseSerializer: XCTestCase {

    var responseSerializer: OpenWeatherAPIClientResponseSerializer?
    
    override func setUp() {
        super.setUp()
        responseSerializer = OpenWeatherAPIClientResponseSerializer()
    }
    
    override func tearDown() {
        responseSerializer = nil
        super.tearDown()
    }
    
    func testResponseSerializerReturnsOnlyAnErrorIfResponseFormatInvalidJSON() {
        let testData = "".dataUsingEncoding(NSUTF8StringEncoding)!
        let result = responseSerializer!.parseForecastsAPIResponseData(testData)
        XCTAssertNil(result.locationInfo)
        XCTAssertNil(result.forecasts)
        XCTAssertEqual("The data couldn’t be read because it isn’t in the correct format.", result.error?.localizedDescription)
    }
    
    func testResponseSerializerReturnsOnlyAnErrorIfResponseFormatIsValidJSONButUnexpectedFormat() {
        let testData = "[]".dataUsingEncoding(NSUTF8StringEncoding)!
        let result = responseSerializer!.parseForecastsAPIResponseData(testData)
        XCTAssertNil(result.locationInfo)
        XCTAssertNil(result.forecasts)
        XCTAssertEqual("The data couldn’t be read because it isn’t in the expected format.", result.error?.localizedDescription)
    }
    
    func testResponseSerializerReturnsOnlyAnErrorIfResponseFormatIsValidButDoesNotContainExpectedData() {
        let testData = "{ \"test\": \"test\" }".dataUsingEncoding(NSUTF8StringEncoding)!
        let result = responseSerializer!.parseForecastsAPIResponseData(testData)
        XCTAssertNil(result.locationInfo)
        XCTAssertNil(result.forecasts)
        XCTAssertEqual("The data couldn’t be read because it doesn’t contain the expected data.", result.error?.localizedDescription)
    }
    
    func testResponseSerializerReturnsOnlyAnErrorIfResponseIsValidButContainsAnError() {
        // A typical example of an incorrect implementation of a REST API, OpenWeatherMap always returns a response and response code 200
        // but if an error occurred the error is embedded within the response object.
        let testData = dataForSampleAPIResponseContainingError()
        let result = responseSerializer!.parseForecastsAPIResponseData(testData)
        XCTAssertNil(result.locationInfo)
        XCTAssertNil(result.forecasts)
        XCTAssertEqual("Error: Not found city", result.error?.localizedDescription)
    }
    
    func testResponseSerializerResultsNoErrorAfterParsingValidAPIResponse() {
        let testData = dataForSampleAPIResponseContainingForecastData()
        let result = responseSerializer!.parseForecastsAPIResponseData(testData)
        XCTAssertNil(result.error)
    }
    
    func testResponseSerializerReturnsCorrectLocationInfoFromValidAPIResponse() {
        let testData = dataForSampleAPIResponseContainingForecastData()
        let result = responseSerializer!.parseForecastsAPIResponseData(testData)
        let expectedLocationInfo = LocationInfo(cityID: "2643743", cityName: "London", cityCountry: "GB")
        XCTAssertEqual(expectedLocationInfo, result.locationInfo)
    }
    
    func testResponseSerializerReturnsCorrectNumberOfForecastsFromValidAPIResponse() {
        let testData = dataForSampleAPIResponseContainingForecastData()
        let result = responseSerializer!.parseForecastsAPIResponseData(testData)
        XCTAssertEqual(40, result.forecasts?.count)
    }
    
    func testResponseSerializerReturnsExpectedForecastDataForFirstSerializedForecast() {
        let testData = dataForSampleAPIResponseContainingForecastData()
        let result = responseSerializer!.parseForecastsAPIResponseData(testData)
        let forecast = result.forecasts?.first
        XCTAssertEqual(forecast?.date, NSDate(timeIntervalSince1970: 1446573600))
        XCTAssertEqual(forecast?.currentTemperature, 12)
        XCTAssertEqual(forecast?.minTemperature, 12)
        XCTAssertEqual(forecast?.maxTemperature, 13)
        XCTAssertEqual(forecast?.cityID, "2643743")
        XCTAssertEqual(forecast?.weather, .Rain)
    }
    
    func testResponseSerializerReturnsExpectedForecastDataForSecondSerializedForecast() {
        let testData = dataForSampleAPIResponseContainingForecastData()
        let result = responseSerializer!.parseForecastsAPIResponseData(testData)
        let forecast = result.forecasts?[1]
        XCTAssertEqual(forecast?.date, NSDate(timeIntervalSince1970: 1446584400))
        XCTAssertEqual(forecast?.currentTemperature, 12)
        XCTAssertEqual(forecast?.minTemperature, 12)
        XCTAssertEqual(forecast?.maxTemperature, 13)
        XCTAssertEqual(forecast?.cityID, "2643743")
        XCTAssertEqual(forecast?.weather, .Rain)
    }
    
    func testResponseSerializerParsesDifferentWeatherConditions() {
        let testData = dataForSampleAPIResponseContainingForecastsWithSampleWeatherCodes()
        let result = responseSerializer!.parseForecastsAPIResponseData(testData)
        var forecast = result.forecasts?.first
        XCTAssertEqual(forecast?.weather, .Danger)
        forecast = result.forecasts?[1]
        XCTAssertEqual(forecast?.weather, .Danger)
        forecast = result.forecasts?[2]
        XCTAssertEqual(forecast?.weather, .Wind)
        forecast = result.forecasts?[3]
        XCTAssertEqual(forecast?.weather, .Clouds)
        forecast = result.forecasts?[4]
        XCTAssertEqual(forecast?.weather, .FewClouds)
        forecast = result.forecasts?[5]
        XCTAssertEqual(forecast?.weather, .Clear)
        forecast = result.forecasts?[6]
        XCTAssertEqual(forecast?.weather, .Mist)
        forecast = result.forecasts?[7]
        XCTAssertEqual(forecast?.weather, .Snow)
        forecast = result.forecasts?[8]
        XCTAssertEqual(forecast?.weather, .ShowerRain)
        forecast = result.forecasts?[9]
        XCTAssertEqual(forecast?.weather, .Rain)
        forecast = result.forecasts?[10]
        XCTAssertEqual(forecast?.weather, .Rain)
        forecast = result.forecasts?[11]
        XCTAssertEqual(forecast?.weather, .Thunderstorm)
    }
    
    func testResponseSerializerReturnsOnlyLocationInfoIfForecastsInfoIsMissingInResponseData() {
        let testData = dataForSampleAPIResponseFromFileNamed("open-weather-api-sample-no-forecasts")
        let result = responseSerializer!.parseForecastsAPIResponseData(testData)
        XCTAssertNotNil(result.locationInfo)
        XCTAssertNil(result.forecasts)
        XCTAssertNil(result.error)
    }
    
    // MARK: - Helpers
    
    func dataForSampleAPIResponseContainingError() -> NSData {
        return dataForSampleAPIResponseFromFileNamed("open-weather-api-sample-error")
    }
    
    func dataForSampleAPIResponseContainingForecastData() -> NSData {
        return dataForSampleAPIResponseFromFileNamed("open-weather-api-sample-success")
    }
    
    func dataForSampleAPIResponseContainingForecastsWithSampleWeatherCodes() -> NSData {
        return dataForSampleAPIResponseFromFileNamed("open-weather-api-sample-weather-codes")
    }
    
    func dataForSampleAPIResponseFromFileNamed(fileName: String) -> NSData {
        let filePath = NSBundle(forClass: self.dynamicType).pathForResource(fileName, ofType: "json")
        let data = NSData(contentsOfFile: filePath!)!
        return data
    }

}

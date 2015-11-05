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
    
    // MARK: - Helpers
    
    func dataForSampleAPIResponseContainingError() -> NSData {
        let filePath = NSBundle(forClass: self.dynamicType).pathForResource("open-weather-api-sample-error", ofType: "json")
        let data = NSData(contentsOfFile: filePath!)!
        return data
    }
    
    func dataForSampleAPIResponseContainingForecastData() -> NSData {
        let filePath = NSBundle(forClass: self.dynamicType).pathForResource("open-weather-api-sample-success", ofType: "json")
        let data = NSData(contentsOfFile: filePath!)!
        return data
    }

}

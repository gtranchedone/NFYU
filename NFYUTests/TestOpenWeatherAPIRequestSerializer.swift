//
//  TestOpenWeatherAPIRequestSerializer.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 05/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import XCTest
import CoreLocation
@testable import NFYU

class TestOpenWeatherAPIRequestSerializer: XCTestCase {

    var requestSerializer: OpenWeatherAPIClientRequestSerializer?
    
    override func setUp() {
        super.setUp()
        requestSerializer = OpenWeatherAPIClientRequestSerializer()
    }
    
    override func tearDown() {
        requestSerializer = nil
        super.tearDown()
    }

    func testRequestSerializerReturnsExpectedURLRequestForFetchingForecastInformation() {
        let appID = NSProcessInfo.processInfo().environment[kOpenWeatherMapAPIKeyEnvironmentVariable]!
        let expectedURLString = "http://api.openweathermap.org/data/2.5/forecast?lat=51.50853&lon=-0.12345&units=metric&appid=\(appID)"
        let coordinate = CLLocationCoordinate2D(latitude: 51.50853, longitude: -0.12345)
        let request = requestSerializer?.buildURLRequestToFetchForecastsForLocationWithCoordinate(coordinate)
        XCTAssertEqual(expectedURLString, request?.URL?.absoluteString)
    }
    
    func testRequestSerializerReturnsExpectedURLRequestForFetchingForecastInformation2() {
        let appID = NSProcessInfo.processInfo().environment[kOpenWeatherMapAPIKeyEnvironmentVariable]!
        let expectedURLString = "http://api.openweathermap.org/data/2.5/forecast?lat=15.50853&lon=-2.12345&units=metric&appid=\(appID)"
        let coordinate = CLLocationCoordinate2D(latitude: 15.50853, longitude: -2.12345)
        let request = requestSerializer?.buildURLRequestToFetchForecastsForLocationWithCoordinate(coordinate)
        XCTAssertEqual(expectedURLString, request?.URL?.absoluteString)
    }

}

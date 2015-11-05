//
//  TestAPIClient.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 05/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import XCTest
import CoreLocation
@testable import NFYU

class TestAPIClient: XCTestCase {

    var apiClient: APIClient?
    
    override func setUp() {
        super.setUp()
        let requestSerializer = FakeRequestSerializer()
        let responseSerializer = FakeResponseSerializer()
        apiClient = APIClient(requestSerializer: requestSerializer, responseSerializer: responseSerializer)
        apiClient?.session = FakeURLSession()
    }
    
    override func tearDown() {
        apiClient = nil
        super.tearDown()
    }
    
    func testAPIClientUsesSharedURLSessionByDefault() {
        apiClient = APIClient(requestSerializer: apiClient!.requestSerializer, responseSerializer: apiClient!.responseSerializer)
        XCTAssertEqual(apiClient?.session, NSURLSession.sharedSession())
    }

    func testAPIClientUsesRequestSerializerToBuildURLRequestForURLSession() {
        apiClient?.fetchForecastsForLocationWithCoordinate(CLLocationCoordinate2D()) { (error, forecasts, locationInfo) in }
        let session = apiClient?.session as? FakeURLSession
        let requestedURLString = session?.lastCreatedDataTask?.originalRequest?.URL?.absoluteString
        XCTAssertEqual("http://google.com", requestedURLString)
    }
    
    func testAPIClientUsesRequestSerializerToBuildURLRequestForURLSession2() {
        let requestSerializer = apiClient?.requestSerializer as? FakeRequestSerializer
        requestSerializer?.stubURLString = "http://apple.com"
        apiClient?.fetchForecastsForLocationWithCoordinate(CLLocationCoordinate2D()) { (error, forecasts, locationInfo) in }
        let session = apiClient?.session as? FakeURLSession
        let requestedURLString = session?.lastCreatedDataTask?.originalRequest?.URL?.absoluteString
        XCTAssertEqual("http://apple.com", requestedURLString)
    }
    
    func testAPIClientStartsTasksAfterCreatingThem() {
        apiClient?.fetchForecastsForLocationWithCoordinate(CLLocationCoordinate2D()) { (error, forecasts, locationInfo) in }
        let session = apiClient?.session as? FakeURLSession
        let task = session?.lastCreatedDataTask as? FakeURLSessionDataTask
        XCTAssertTrue(task!.started)
    }
    
    func testAPIClientCallsCompletionBlockWithErrorIfTaskCompletesWithError() {
        var receivedError: NSError?
        apiClient?.fetchForecastsForLocationWithCoordinate(CLLocationCoordinate2D()) { (error, forecasts, locationInfo) in
            receivedError = error
        }
        let session = apiClient?.session as? FakeURLSession
        let task = session?.lastCreatedDataTask as? FakeURLSessionDataTask
        let stubError = NSError(domain: "testDomain", code: 400, userInfo: nil)
        task?.completionHandler?(nil, nil, stubError)
        XCTAssertEqual(stubError, receivedError)
    }
    
    func testAPIClientCallsCompletionBlockWithForecastsParsedByResponseSerializer() {
        var receivedForecasts: [Forecast]?
        apiClient?.fetchForecastsForLocationWithCoordinate(CLLocationCoordinate2D()) { (error, forecasts, locationInfo) in
            receivedForecasts = forecasts
        }
        let session = apiClient?.session as? FakeURLSession
        let task = session?.lastCreatedDataTask as? FakeURLSessionDataTask
        let responseSerializer = apiClient?.responseSerializer as? FakeResponseSerializer
        let forecast = Forecast(date: NSDate(), cityID: "cityID1", weather: .Clear, minTemperature: 0, maxTemperature: 0, currentTemperature: 0)
        responseSerializer?.stubForecasts = [forecast]
        task?.completionHandler?(NSData(), nil, nil)
        XCTAssertEqual(responseSerializer!.stubForecasts!, receivedForecasts!)
    }
    
    func testAPIClientCallsCompletionBlockWithCityLocationParsedByResponseSerializer() {
        var receivedLocationInfo: LocationInfo?
        apiClient?.fetchForecastsForLocationWithCoordinate(CLLocationCoordinate2D()) { (error, forecasts, locationInfo) in
            receivedLocationInfo = locationInfo
        }
        let session = apiClient?.session as? FakeURLSession
        let task = session?.lastCreatedDataTask as? FakeURLSessionDataTask
        let responseSerializer = apiClient?.responseSerializer as? FakeResponseSerializer
        responseSerializer?.stubLocationInfo = LocationInfo(cityID: "testID", cityName: "testCity", cityCountry: "testCountry")
        task?.completionHandler?(NSData(), nil, nil)
        XCTAssertEqual(responseSerializer!.stubLocationInfo, receivedLocationInfo)
    }
    
    func testAPIClientCallsCompletionBlockWithErrorParsedByResponseSerializer() {
        var receivedError: NSError?
        apiClient?.fetchForecastsForLocationWithCoordinate(CLLocationCoordinate2D()) { (error, forecasts, locationInfo) in
            receivedError = error
        }
        let session = apiClient?.session as? FakeURLSession
        let task = session?.lastCreatedDataTask as? FakeURLSessionDataTask
        let responseSerializer = apiClient?.responseSerializer as? FakeResponseSerializer
        responseSerializer?.stubError = NSError(domain: "testError", code: 404, userInfo: nil)
        task?.completionHandler?(NSData(), nil, nil)
        XCTAssertEqual(responseSerializer!.stubError, receivedError)
    }

}

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
        XCTAssertEqual(apiClient?.session, URLSession.shared)
    }

    func testAPIClientUsesRequestSerializerToBuildURLRequestForURLSession() {
        apiClient?.fetchForecastsForLocationWithCoordinate(CLLocationCoordinate2D()) { (error, forecasts, locationInfo) in }
        let session = apiClient?.session as? FakeURLSession
        let requestedURLString = session?.lastCreatedDataTask?.originalRequest?.url?.absoluteString
        XCTAssertEqual("http://google.com", requestedURLString)
    }
    
    func testAPIClientUsesRequestSerializerToBuildURLRequestForURLSession2() {
        let requestSerializer = apiClient?.requestSerializer as? FakeRequestSerializer
        requestSerializer?.stubURLString = "http://apple.com"
        apiClient?.fetchForecastsForLocationWithCoordinate(CLLocationCoordinate2D()) { (error, forecasts, locationInfo) in }
        let session = apiClient?.session as? FakeURLSession
        let requestedURLString = session?.lastCreatedDataTask?.originalRequest?.url?.absoluteString
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
        let expectation = self.expectation(description: "Expect API client to call its completion block")
        apiClient?.fetchForecastsForLocationWithCoordinate(CLLocationCoordinate2D()) { (error, forecasts, locationInfo) in
            receivedError = error
            expectation.fulfill()
        }
        let session = apiClient?.session as? FakeURLSession
        let task = session?.lastCreatedDataTask as? FakeURLSessionDataTask
        let stubError = NSError(domain: "testDomain", code: 400, userInfo: nil)
        task?.completionHandler?(nil, nil, stubError)
        waitForExpectations(timeout: 1.0, handler: nil)
        XCTAssertEqual(stubError, receivedError)
    }
    
    func testAPIClientCallsCompletionBlockWithForecastsParsedByResponseSerializer() {
        var receivedForecasts: [Forecast]?
        let expectation = self.expectation(description: "Expect API client to call its completion block")
        apiClient?.fetchForecastsForLocationWithCoordinate(CLLocationCoordinate2D()) { (error, forecasts, locationInfo) in
            receivedForecasts = forecasts
            expectation.fulfill()
        }
        let session = apiClient?.session as? FakeURLSession
        let task = session?.lastCreatedDataTask as? FakeURLSessionDataTask
        let responseSerializer = apiClient?.responseSerializer as? FakeResponseSerializer
        let forecast = Forecast(date: Date(), cityID: "cityID1", weather: .Clear, minTemperature: 0, maxTemperature: 0, currentTemperature: 0)
        responseSerializer?.stubForecasts = [forecast]
        task?.completionHandler?(Data(), nil, nil)
        waitForExpectations(timeout: 1.0, handler: nil)
        XCTAssertEqual(responseSerializer!.stubForecasts!, receivedForecasts!)
    }
    
    func testAPIClientCallsCompletionBlockWithCityLocationParsedByResponseSerializer() {
        var receivedLocationInfo: LocationInfo?
        let expectation = self.expectation(description: "Expect API client to call its completion block")
        apiClient?.fetchForecastsForLocationWithCoordinate(CLLocationCoordinate2D()) { (error, forecasts, locationInfo) in
            receivedLocationInfo = locationInfo
            expectation.fulfill()
        }
        let session = apiClient?.session as? FakeURLSession
        let task = session?.lastCreatedDataTask as? FakeURLSessionDataTask
        let responseSerializer = apiClient?.responseSerializer as? FakeResponseSerializer
        responseSerializer?.stubLocationInfo = LocationInfo(id: "testID", name: "testCity", country: "testCountry")
        task?.completionHandler?(Data(), nil, nil)
        waitForExpectations(timeout: 1.0, handler: nil)
        XCTAssertEqual(responseSerializer!.stubLocationInfo, receivedLocationInfo)
    }
    
    func testAPIClientCallsCompletionBlockWithErrorParsedByResponseSerializer() {
        var receivedError: NSError?
        let expectation = self.expectation(description: "Expect API client to call its completion block")
        apiClient?.fetchForecastsForLocationWithCoordinate(CLLocationCoordinate2D()) { (error, forecasts, locationInfo) in
            receivedError = error
            expectation.fulfill()
        }
        let session = apiClient?.session as? FakeURLSession
        let task = session?.lastCreatedDataTask as? FakeURLSessionDataTask
        let responseSerializer = apiClient?.responseSerializer as? FakeResponseSerializer
        responseSerializer?.stubError = NSError(domain: "testError", code: 404, userInfo: nil)
        task?.completionHandler?(Data(), nil, nil)
        waitForExpectations(timeout: 1.0, handler: nil)
        XCTAssertEqual(responseSerializer!.stubError, receivedError)
    }

}

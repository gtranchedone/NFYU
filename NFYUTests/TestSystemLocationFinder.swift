//
//  TestSystemLocationManager.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 03/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import XCTest
import CoreLocation
@testable import NFYU

class TestSystemUserLocationManager: XCTestCase {

    var systemLocationFinder: SystemUserLocationFinder?
    var fakeLocationManager: FakeLocationManager?
    
    override func setUp() {
        super.setUp()
        fakeLocationManager = FakeLocationManager()
        systemLocationFinder = SystemUserLocationFinder(locationManager: fakeLocationManager)
    }
    
    override func tearDown() {
        FakeLocationManager.stubAuthorizationStatus = .NotDetermined
        systemLocationFinder = nil
        super.tearDown()
    }
    
    func testInfoPlistContainsRequiredInfoForUsingLocationServices() {
        XCTAssertNotNil(NSBundle.mainBundle().objectForInfoDictionaryKey("NSLocationWhenInUseUsageDescription"))
    }
    
    func testSystemLocationFinderSetsItselfAsTheLocationManagerDelegate() {
        XCTAssertTrue(fakeLocationManager!.delegate === systemLocationFinder)
    }

    // MARK: Authorization for Use of Location Services
    
    func testSystemLocationFinderReturnsTheLocationManagerInfoAboutTheAppCapabilityOfUsingLocationServices() {
        XCTAssertFalse(systemLocationFinder!.locationServicesEnabled())
    }
    
    func testSystemLocationFinderReturnsTheLocationManagerInfoAboutTheAppCapabilityOfUsingLocationServices2() {
        FakeLocationManager.stubAuthorizationStatus = .AuthorizedWhenInUse
        XCTAssertTrue(systemLocationFinder!.locationServicesEnabled())
    }
    
    func testSystemLocationFinderRequestsLocationUsageAuthorizationIfNeeded() {
        systemLocationFinder?.requestCurrentLocation { _, _ in }
        XCTAssertTrue(fakeLocationManager!.didRequestAuthorizationForInUse)
    }
    
    func testSystemLocationFinderRequestsLocationUsageAuthorizationIfAlreadyAuthorized() {
        FakeLocationManager.stubAuthorizationStatus = .AuthorizedWhenInUse
        systemLocationFinder?.requestCurrentLocation { _, _ in }
        XCTAssertFalse(fakeLocationManager!.didRequestAuthorizationForInUse)
    }
    
    func testSystemLocationFinderRequestsLocationUsageAuthorizationIfAlreadyDenied() {
        FakeLocationManager.stubAuthorizationStatus = .Denied
        systemLocationFinder?.requestCurrentLocation { _, _ in }
        XCTAssertFalse(fakeLocationManager!.didRequestAuthorizationForInUse)
    }
    
    // MARK: Requesting Location Updates
    
    func testSystemLocationFinderCallsCompletionBlockWithErrorIfLocationServicesAuthorizationIsDenied() {
        FakeLocationManager.stubAuthorizationStatus = .Denied
        let expectation = expectationWithDescription("Location update request calls completion block")
        systemLocationFinder?.requestCurrentLocation { error, location in
            XCTAssertNotNil(error)
            XCTAssertNil(location)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
    
    func testSystemLocationFinderCallsCompletionBlockWithErrorIfLocationServicesAuthorizationIsRestricted() {
        FakeLocationManager.stubAuthorizationStatus = .Restricted
        let expectation = expectationWithDescription("Location update request calls completion block")
        systemLocationFinder?.requestCurrentLocation { error, location in
            XCTAssertNotNil(error)
            XCTAssertNil(location)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
    
    func testSystemLocationFinderCallsCompletionBlockWithErrorIfLocationServicesAuthorizationBecomesDenied() {
        let expectation = expectationWithDescription("Location update request calls completion block")
        systemLocationFinder?.requestCurrentLocation { error, location in
            XCTAssertNotNil(error)
            XCTAssertNil(location)
            expectation.fulfill()
        }
        FakeLocationManager.stubAuthorizationStatus = .Denied
        systemLocationFinder?.locationManager(fakeLocationManager!, didChangeAuthorizationStatus: .Denied)
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
    
    func testSystemLocationFinderCallsCompletionBlockWithErrorIfLocationServicesAuthorizationBecomesRestricted() {
        let expectation = expectationWithDescription("Location update request calls completion block")
        systemLocationFinder?.requestCurrentLocation { error, location in
            XCTAssertNotNil(error)
            XCTAssertNil(location)
            expectation.fulfill()
        }
        FakeLocationManager.stubAuthorizationStatus = .Restricted
        systemLocationFinder?.locationManager(fakeLocationManager!, didChangeAuthorizationStatus: .Restricted)
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
    
    func testSystemLocationFinderForwardsRequestForUpdatingCurrentLocationToLocationManager() {
        FakeLocationManager.stubAuthorizationStatus = .AuthorizedWhenInUse
        systemLocationFinder?.requestCurrentLocation { _, _ in }
        XCTAssertTrue(fakeLocationManager!.didRequestLocation)
    }
    
    func testSystemLocationFinderCallsCompletionBlockWithErrorIfLocationManagerFailsToUpdateLocation() {
        let expectation = expectationWithDescription("Location update request calls completion block")
        systemLocationFinder?.requestCurrentLocation { error, location in
            XCTAssertNotNil(error)
            XCTAssertNil(location)
            expectation.fulfill()
        }
        let error = NSError(domain: "testDomain", code: 400, userInfo: nil)
        systemLocationFinder?.locationManager(fakeLocationManager!, didFailWithError: error)
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
    
    func testSystemLocationFinderCallsCompletionBlockWithLastFoundLocationIfLocationManagerSucceedsInUpdatingLocation() {
        let expectation = expectationWithDescription("Location update request calls completion block")
        systemLocationFinder?.requestCurrentLocation { error, location in
            XCTAssertNil(error)
            XCTAssertNotNil(location)
            expectation.fulfill()
        }
        let locations: [CLLocation] = [CLLocation(latitude: 0, longitude: 0)]
        systemLocationFinder?.locationManager(fakeLocationManager!, didUpdateLocations: locations)
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }

}

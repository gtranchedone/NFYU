//
//  TestSystemLocationManager.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 03/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import XCTest
@testable import NFYU

class TestSystemLocationFinder: XCTestCase {

    var systemLocationFinder: SystemLocationFinder?
    var fakeLocationManager: FakeLocationManager?
    
    override func setUp() {
        super.setUp()
        fakeLocationManager = FakeLocationManager()
        systemLocationFinder = SystemLocationFinder(locationManager: fakeLocationManager)
    }
    
    override func tearDown() {
        FakeLocationManager.stubAuthorizationStatus = .NotDetermined
        systemLocationFinder = nil
        super.tearDown()
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
        XCTAssertTrue(fakeLocationManager!.didStartUpdatingLocation)
    }
    
// NOTE: this is a reminder for what I have to do next
//    func testSystemLocationFinderStopsUpdatingLocationsIfLocationManagerFailsToUpdateLocation() {
//        XCTFail()
//    }
//    
//    func testSystemLocationFinderStopsUpdatingLocationsIfLocationManagerSucceedsInUpdatingLocation() {
//        XCTFail()
//    }
//    
//    func testSystemLocationFinderCallsCompletionBlockWithErrorIfLocationManagerFailsToUpdateLocation() {
//        XCTFail()
//    }
//    
//    func testSystemLocationFinderCallsCompletionBlockWithLastFoundLocationIfLocationManagerSucceedsInUpdatingLocation() {
//        XCTFail()
//    }

}

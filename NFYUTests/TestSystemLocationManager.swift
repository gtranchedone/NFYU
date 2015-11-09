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

    var systemLocationManager: SystemUserLocationManager?
    var fakeLocationManager: FakeLocationManager?
    
    override func setUp() {
        super.setUp()
        fakeLocationManager = FakeLocationManager()
        systemLocationManager = SystemUserLocationManager(locationManager: fakeLocationManager)
    }
    
    override func tearDown() {
        FakeLocationManager.stubAuthorizationStatus = .NotDetermined
        systemLocationManager = nil
        super.tearDown()
    }
    
    func testInfoPlistContainsRequiredInfoForUsingLocationServices() {
        XCTAssertNotNil(NSBundle.mainBundle().objectForInfoDictionaryKey("NSLocationWhenInUseUsageDescription"))
    }
    
    func testSystemLocationManagerSetsItselfAsTheLocationManagerDelegate() {
        XCTAssertTrue(fakeLocationManager!.delegate === systemLocationManager)
    }

    // MARK: Authorization for Use of Location Services
    
    func testSystemLocationManagerDidNotRequestAuthorizationIfPermissionsAreNotDetermined() {
        XCTAssertFalse(systemLocationManager!.didRequestAuthorization)
    }
    
    func testSystemLocationManagerDidNotRequestAuthorizationIfPermissionsAreGranted() {
        FakeLocationManager.stubAuthorizationStatus = .AuthorizedWhenInUse
        XCTAssertTrue(systemLocationManager!.didRequestAuthorization)
    }
    
    func testSystemLocationManagerDidNotRequestAuthorizationIfPermissionsAreDenied() {
        FakeLocationManager.stubAuthorizationStatus = .Denied
        XCTAssertTrue(systemLocationManager!.didRequestAuthorization)
    }
    
    func testSystemLocationManagerDidNotRequestAuthorizationIfPermissionsAreRestricted() {
        FakeLocationManager.stubAuthorizationStatus = .Restricted
        XCTAssertTrue(systemLocationManager!.didRequestAuthorization)
    }
    
    func testSystemLocationManagerShouldNotRequestAuthorizationIfPermissionsAreGranted() {
        FakeLocationManager.stubAuthorizationStatus = .AuthorizedWhenInUse
        XCTAssertFalse(systemLocationManager!.requestUserAuthorizationForUsingLocationServices(nil))
    }
    
    func testSystemLocationManagerShouldNotRequestAuthorizationIfPermissionsAreDenied() {
        FakeLocationManager.stubAuthorizationStatus = .Denied
        XCTAssertFalse(systemLocationManager!.requestUserAuthorizationForUsingLocationServices(nil))
    }
    
    func testSystemLocationManagerShouldNotRequestAuthorizationIfPermissionsAreRestricted() {
        FakeLocationManager.stubAuthorizationStatus = .Restricted
        XCTAssertFalse(systemLocationManager!.requestUserAuthorizationForUsingLocationServices(nil))
    }
    
    func testSystemLocationManagerDoesNotAllowUsageOfLocationServicesWhenPermissionIsNotDetermined() {
        XCTAssertFalse(systemLocationManager!.locationServicesEnabled)
    }
    
    func testSystemLocationManagerAllowsUsageOfLocationServicesWhenPermissionIsGranted() {
        FakeLocationManager.stubAuthorizationStatus = .AuthorizedWhenInUse
        XCTAssertTrue(systemLocationManager!.locationServicesEnabled)
    }
    
    func testSystemLocationManagerDoesNotAllowUsageOfLocationServicesWhenPermissionIsDenied() {
        FakeLocationManager.stubAuthorizationStatus = .Denied
        XCTAssertFalse(systemLocationManager!.locationServicesEnabled)
    }
    
    func testSystemLocationManagerDoesNotAllowUsageOfLocationServicesWhenPermissionIsRestricted() {
        FakeLocationManager.stubAuthorizationStatus = .Restricted
        XCTAssertFalse(systemLocationManager!.locationServicesEnabled)
    }
    
    // MARK: Requesting Location Updates
    
    func testSystemLocationManagerRequestsLocationUsageAuthorizationIfNeeded() {
        systemLocationManager?.requestCurrentLocation { _, _ in }
        XCTAssertTrue(fakeLocationManager!.didRequestAuthorizationForInUse)
    }
    
    func testSystemLocationManagerRequestsLocationUsageAuthorizationIfAlreadyAuthorized() {
        FakeLocationManager.stubAuthorizationStatus = .AuthorizedWhenInUse
        systemLocationManager?.requestCurrentLocation { _, _ in }
        XCTAssertFalse(fakeLocationManager!.didRequestAuthorizationForInUse)
    }
    
    func testSystemLocationManagerDoesNotRequestLocationUsageAuthorizationIfAlreadyDenied() {
        FakeLocationManager.stubAuthorizationStatus = .Denied
        systemLocationManager?.requestCurrentLocation { _, _ in }
        XCTAssertFalse(fakeLocationManager!.didRequestAuthorizationForInUse)
    }
    
    func testSystemLocationManagerCallsCompletionBlockWithErrorIfLocationServicesAuthorizationIsDenied() {
        FakeLocationManager.stubAuthorizationStatus = .Denied
        let expectation = expectationWithDescription("Location update request calls completion block")
        systemLocationManager?.requestCurrentLocation { error, location in
            XCTAssertNotNil(error)
            XCTAssertNil(location)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
    
    func testSystemLocationManagerCallsCompletionBlockWithErrorIfLocationServicesAuthorizationIsRestricted() {
        FakeLocationManager.stubAuthorizationStatus = .Restricted
        let expectation = expectationWithDescription("Location update request calls completion block")
        systemLocationManager?.requestCurrentLocation { error, location in
            XCTAssertNotNil(error)
            XCTAssertNil(location)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
    
    func testSystemLocationManagerCallsCompletionBlockWithErrorIfLocationServicesAuthorizationBecomesDenied() {
        let expectation = expectationWithDescription("Location update request calls completion block")
        systemLocationManager?.requestCurrentLocation { error, location in
            XCTAssertNotNil(error)
            XCTAssertNil(location)
            expectation.fulfill()
        }
        FakeLocationManager.stubAuthorizationStatus = .Denied
        systemLocationManager?.locationManager(fakeLocationManager!, didChangeAuthorizationStatus: .Denied)
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
    
    func testSystemLocationManagerCallsCompletionBlockWithErrorIfLocationServicesAuthorizationBecomesRestricted() {
        let expectation = expectationWithDescription("Location update request calls completion block")
        systemLocationManager?.requestCurrentLocation { error, location in
            XCTAssertNotNil(error)
            XCTAssertNil(location)
            expectation.fulfill()
        }
        FakeLocationManager.stubAuthorizationStatus = .Restricted
        systemLocationManager?.locationManager(fakeLocationManager!, didChangeAuthorizationStatus: .Restricted)
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
    
    func testSystemLocationManagerForwardsRequestForUpdatingCurrentLocationToLocationManager() {
        FakeLocationManager.stubAuthorizationStatus = .AuthorizedWhenInUse
        systemLocationManager?.requestCurrentLocation { _, _ in }
        XCTAssertTrue(fakeLocationManager!.didRequestLocation)
    }
    
    func testSystemLocationManagerCallsCompletionBlockWithErrorIfLocationManagerFailsToUpdateLocation() {
        let expectation = expectationWithDescription("Location update request calls completion block")
        systemLocationManager?.requestCurrentLocation { error, location in
            XCTAssertNotNil(error)
            XCTAssertNil(location)
            expectation.fulfill()
        }
        let error = NSError(domain: "testDomain", code: 400, userInfo: nil)
        systemLocationManager?.locationManager(fakeLocationManager!, didFailWithError: error)
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
    
    func testSystemLocationManagerCallsCompletionBlockWithLastFoundLocationIfLocationManagerSucceedsInUpdatingLocation() {
        let expectation = expectationWithDescription("Location update request calls completion block")
        systemLocationManager?.requestCurrentLocation { error, location in
            XCTAssertNil(error)
            XCTAssertNotNil(location)
            expectation.fulfill()
        }
        let locations: [CLLocation] = [CLLocation(latitude: 0, longitude: 0)]
        systemLocationManager?.locationManager(fakeLocationManager!, didUpdateLocations: locations)
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }

}

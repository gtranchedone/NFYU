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
        FakeLocationManager.stubAuthorizationStatus = .notDetermined
        systemLocationManager = nil
        super.tearDown()
    }
    
    func testInfoPlistContainsRequiredInfoForUsingLocationServices() {
        XCTAssertNotNil(Bundle.main.object(forInfoDictionaryKey: "NSLocationWhenInUseUsageDescription"))
    }
    
    func testSystemLocationManagerSetsItselfAsTheLocationManagerDelegate() {
        XCTAssertTrue(fakeLocationManager!.delegate === systemLocationManager)
    }

    // MARK: Authorization for Use of Location Services
    
    func testSystemLocationManagerDidNotRequestAuthorizationIfPermissionsAreNotDetermined() {
        XCTAssertFalse(systemLocationManager!.didRequestAuthorization)
    }
    
    func testSystemLocationManagerDidNotRequestAuthorizationIfPermissionsAreGranted() {
        FakeLocationManager.stubAuthorizationStatus = .authorizedWhenInUse
        XCTAssertTrue(systemLocationManager!.didRequestAuthorization)
    }
    
    func testSystemLocationManagerDidNotRequestAuthorizationIfPermissionsAreDenied() {
        FakeLocationManager.stubAuthorizationStatus = .denied
        XCTAssertTrue(systemLocationManager!.didRequestAuthorization)
    }
    
    func testSystemLocationManagerDidNotRequestAuthorizationIfPermissionsAreRestricted() {
        FakeLocationManager.stubAuthorizationStatus = .restricted
        XCTAssertTrue(systemLocationManager!.didRequestAuthorization)
    }
    
    func testSystemLocationManagerShouldNotRequestAuthorizationIfPermissionsAreGranted() {
        FakeLocationManager.stubAuthorizationStatus = .authorizedWhenInUse
        XCTAssertFalse(systemLocationManager!.requestUserAuthorizationForUsingLocationServices({}))
    }
    
    func testSystemLocationManagerShouldNotRequestAuthorizationIfPermissionsAreDenied() {
        FakeLocationManager.stubAuthorizationStatus = .denied
        XCTAssertFalse(systemLocationManager!.requestUserAuthorizationForUsingLocationServices({}))
    }
    
    func testSystemLocationManagerShouldNotRequestAuthorizationIfPermissionsAreRestricted() {
        FakeLocationManager.stubAuthorizationStatus = .restricted
        XCTAssertFalse(systemLocationManager!.requestUserAuthorizationForUsingLocationServices({}))
    }
    
    func testSystemLocationManagerDoesNotAllowUsageOfLocationServicesWhenPermissionIsNotDetermined() {
        XCTAssertFalse(systemLocationManager!.locationServicesEnabled)
    }
    
    func testSystemLocationManagerAllowsUsageOfLocationServicesWhenPermissionIsGranted() {
        FakeLocationManager.stubAuthorizationStatus = .authorizedWhenInUse
        XCTAssertTrue(systemLocationManager!.locationServicesEnabled)
    }
    
    func testSystemLocationManagerDoesNotAllowUsageOfLocationServicesWhenPermissionIsDenied() {
        FakeLocationManager.stubAuthorizationStatus = .denied
        XCTAssertFalse(systemLocationManager!.locationServicesEnabled)
    }
    
    func testSystemLocationManagerDoesNotAllowUsageOfLocationServicesWhenPermissionIsRestricted() {
        FakeLocationManager.stubAuthorizationStatus = .restricted
        XCTAssertFalse(systemLocationManager!.locationServicesEnabled)
    }
    
    // MARK: Requesting Location Updates
    
    func testSystemLocationManagerRequestsLocationUsageAuthorizationIfNeeded() {
        systemLocationManager?.requestCurrentLocation { _, _ in }
        XCTAssertTrue(fakeLocationManager!.didRequestAuthorizationForInUse)
    }
    
    func testSystemLocationManagerRequestsLocationUsageAuthorizationIfAlreadyAuthorized() {
        FakeLocationManager.stubAuthorizationStatus = .authorizedWhenInUse
        systemLocationManager?.requestCurrentLocation { _, _ in }
        XCTAssertFalse(fakeLocationManager!.didRequestAuthorizationForInUse)
    }
    
    func testSystemLocationManagerDoesNotRequestLocationUsageAuthorizationIfAlreadyDenied() {
        FakeLocationManager.stubAuthorizationStatus = .denied
        systemLocationManager?.requestCurrentLocation { _, _ in }
        XCTAssertFalse(fakeLocationManager!.didRequestAuthorizationForInUse)
    }
    
    func testSystemLocationManagerCallsCompletionBlockWithErrorIfLocationServicesAuthorizationIsDenied() {
        FakeLocationManager.stubAuthorizationStatus = .denied
        let expectation = self.expectation(description: "Location update request calls completion block")
        systemLocationManager?.requestCurrentLocation { error, location in
            XCTAssertNotNil(error)
            XCTAssertNil(location)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testSystemLocationManagerCallsCompletionBlockWithErrorIfLocationServicesAuthorizationIsRestricted() {
        FakeLocationManager.stubAuthorizationStatus = .restricted
        let expectation = self.expectation(description: "Location update request calls completion block")
        systemLocationManager?.requestCurrentLocation { error, location in
            XCTAssertNotNil(error)
            XCTAssertNil(location)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testSystemLocationManagerCallsCompletionBlockWithErrorIfLocationServicesAuthorizationBecomesDenied() {
        let expectation = self.expectation(description: "Location update request calls completion block")
        systemLocationManager?.requestCurrentLocation { error, location in
            XCTAssertNotNil(error)
            XCTAssertNil(location)
            expectation.fulfill()
        }
        FakeLocationManager.stubAuthorizationStatus = .denied
        systemLocationManager?.locationManager(fakeLocationManager!, didChangeAuthorization: .denied)
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testSystemLocationManagerCallsCompletionBlockWithErrorIfLocationServicesAuthorizationBecomesRestricted() {
        let expectation = self.expectation(description: "Location update request calls completion block")
        systemLocationManager?.requestCurrentLocation { error, location in
            XCTAssertNotNil(error)
            XCTAssertNil(location)
            expectation.fulfill()
        }
        FakeLocationManager.stubAuthorizationStatus = .restricted
        systemLocationManager?.locationManager(fakeLocationManager!, didChangeAuthorization: .restricted)
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testSystemLocationManagerForwardsRequestForUpdatingCurrentLocationToLocationManager() {
        FakeLocationManager.stubAuthorizationStatus = .authorizedWhenInUse
        systemLocationManager?.requestCurrentLocation { _, _ in }
        XCTAssertTrue(fakeLocationManager!.didRequestLocation)
    }
    
    func testSystemLocationManagerCallsCompletionBlockWithErrorIfLocationManagerFailsToUpdateLocation() {
        let expectation = self.expectation(description: "Location update request calls completion block")
        systemLocationManager?.requestCurrentLocation { error, location in
            XCTAssertNotNil(error)
            XCTAssertNil(location)
            expectation.fulfill()
        }
        let error = NSError(domain: "testDomain", code: 400, userInfo: nil)
        systemLocationManager?.locationManager(fakeLocationManager!, didFailWithError: error)
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testSystemLocationManagerCallsCompletionBlockWithLastFoundLocationIfLocationManagerSucceedsInUpdatingLocation() {
        let expectation = self.expectation(description: "Location update request calls completion block")
        systemLocationManager?.requestCurrentLocation { error, location in
            XCTAssertNil(error)
            XCTAssertNotNil(location)
            expectation.fulfill()
        }
        let locations: [CLLocation] = [CLLocation(latitude: 0, longitude: 0)]
        systemLocationManager?.locationManager(fakeLocationManager!, didUpdateLocations: locations)
        waitForExpectations(timeout: 1.0, handler: nil)
    }

}

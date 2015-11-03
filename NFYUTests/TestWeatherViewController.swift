//
//  TestWeatherViewController.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 01/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import XCTest
@testable import NFYU

class TestWeatherViewController: XCTestCase {

    var viewController: WeatherViewController?
    
    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        viewController = storyboard.instantiateInitialViewController() as? WeatherViewController
        viewController?.locationManager = FakeLocationFinder()
        viewController?.userDefaults = FakeUserDefaults()
    }
    
    override func tearDown() {
        viewController = nil
        super.tearDown()
    }
    
    // MARK: Initial UI State
    
    func testWeatherViewControllerCanBeCorrectlyInitialized() {
        XCTAssertNotNil(viewController)
    }
    
    func testWeatherViewControllerHasSetupViewHiddenByDefault() {
        viewController?.userDefaults = nil
        loadViewControllerView()
        XCTAssertFalse(viewController!.initialSetupView.hidden)
    }
    
    func testWeatherViewControllerHasActivityIndicatorHiddenByDefault() {
        loadViewControllerView()
        XCTAssertTrue(viewController!.activityIndicator.hidden)
    }
    
    func testWeatherViewControllerHasBackgroundMessageLabelHiddenByDefault() {
        loadViewControllerView()
        XCTAssertTrue(viewController!.backgroundMessageLabel.hidden)
    }
    
    func testWeatherViewControllerHasPageControlHiddenByDefault() {
        loadViewControllerView()
        XCTAssertTrue(viewController!.pageControl.hidden)
    }
    
    func testWeatherViewControllerShowsInitialSetUpViewIfUserDidNotYetSetUpLocations() {
        viewController!.userDefaults!.didSetUpLocations = false
        loadViewControllerView()
        XCTAssertFalse(viewController!.initialSetupView.hidden)
    }
    
    func testWeatherViewControllerHidesInitialSetUpViewIfUserDidAlreadySetUpLocations() {
        viewController!.userDefaults!.didSetUpLocations = true
        loadViewControllerView()
        XCTAssertTrue(viewController!.initialSetupView.hidden)
    }
    
    func testWeatherViewControllerHidesSettingsButtonWhenShowingInitialSetupView() {
        viewController!.userDefaults!.didSetUpLocations = false
        loadViewControllerView()
        XCTAssertTrue(viewController!.settingsButton.hidden)
    }
    
    func testWeatherViewControllerShowsSettingsButtonWhenNotShowingInitialSetupView() {
        viewController!.userDefaults!.didSetUpLocations = true
        loadViewControllerView()
        XCTAssertFalse(viewController!.settingsButton.hidden)
    }
    
    // MARK: Using Device Location
    
    func testWeatherViewControllerUpdatesUserDefaultsForUsingCurrentLocationIfUserChoosesToUseCurrentLocationForForecastsOnInitialSetUp() {
        loadViewControllerView()
        viewController!.initialSetupView.useLocationButton.sendActionsForControlEvents(.TouchUpInside)
        XCTAssertTrue(viewController!.userDefaults!.canUseUserLocation)
    }
    
    func testWeatherViewControllerUpdatesUserDefaultsForHavingSetupLocationsIfUserChoosesToUseCurrentLocationForForecastsOnInitialSetUp() {
        loadViewControllerView()
        viewController!.initialSetupView.useLocationButton.sendActionsForControlEvents(.TouchUpInside)
        XCTAssertTrue(viewController!.userDefaults!.didSetUpLocations)
    }
    
    func testWeatherViewControllerHidesInitialSetupViewIfUserChoosesToUseCurrentLocationForForecastsOnInitialSetUp() {
        loadViewControllerView()
        viewController!.initialSetupView.useLocationButton.sendActionsForControlEvents(.TouchUpInside)
        XCTAssertTrue(viewController!.initialSetupView.hidden)
    }
    
    func testWeatherViewControllerRequestsUserLocationIfUserChoosesToUseItForForecastsOnInitialSetUp() {
        loadViewControllerView()
        viewController!.initialSetupView.useLocationButton.sendActionsForControlEvents(.TouchUpInside)
        let locationManager = viewController!.locationManager as! FakeLocationFinder
        XCTAssertTrue(locationManager.didRequestCurrentLocation)
    }
    
    func testWeatherViewControllerRequestsUserLocationWhenIsAboutToAppearOnScreenIfUserChoosedToUseItForForecasts() {
        viewController!.userDefaults!.canUseUserLocation = true
        loadViewControllerView()
        let locationManager = viewController!.locationManager as! FakeLocationFinder
        XCTAssertTrue(locationManager.didRequestCurrentLocation)
    }
    
    func testWeatherViewControllerDoesNotRequestUserLocationWhenIsAboutToAppearOnScreenIfUserChoosedNotToUseItForForecasts() {
        viewController!.userDefaults!.canUseUserLocation = false
        loadViewControllerView()
        let locationManager = viewController!.locationManager as! FakeLocationFinder
        XCTAssertFalse(locationManager.didRequestCurrentLocation)
    }
    
    func testWeatherViewControllerDoesNotRequestUserLocationWhenIsAboutToAppearOnScreenIfUserHasNotYetDecidedIfToUseItForForecasts() {
        loadViewControllerView()
        let locationManager = viewController!.locationManager as! FakeLocationFinder
        XCTAssertFalse(locationManager.didRequestCurrentLocation)
    }
    
    func testWeatherViewControllerShowsLoadingIndicatorWhileLoadingLocation() {
        viewController!.userDefaults!.canUseUserLocation = true
        let locationManager = viewController!.locationManager as! FakeLocationFinder
        locationManager.shouldCallCompletionBlock = false
        loadViewControllerView()
        XCTAssertFalse(viewController!.activityIndicator.hidden)
        XCTAssertTrue(viewController!.activityIndicator!.isAnimating())
    }
    
    func testWeatherViewControllerHidesLoadingIndicatorAfterLocationHasBeenLoaded() {
        viewController!.userDefaults!.canUseUserLocation = true
        loadViewControllerView()
        XCTAssertTrue(viewController!.activityIndicator.hidden)
        XCTAssertFalse(viewController!.activityIndicator!.isAnimating())
    }
    
    func testWeatherViewControllerShowsLocalizedErrorMessageFromLocationManagerWhenRequestForLoadingCurrentLocationFails() {
        viewController!.userDefaults!.canUseUserLocation = true
        let locationManager = viewController!.locationManager as! FakeLocationFinder
        let expectedErrorMessage = "Some error message"
        let stubUserInfo = [NSLocalizedDescriptionKey: expectedErrorMessage]
        locationManager.stubError = NSError(domain: "test", code: 400, userInfo: stubUserInfo)
        loadViewControllerView()
        XCTAssertFalse(viewController!.backgroundMessageLabel.hidden)
        XCTAssertEqual(expectedErrorMessage, viewController!.backgroundMessageLabel.text)
    }
    
    // MARK: Selecting Cities
    
    // TODO: actually hide the initialSetupView only if the user is done adding cities -> use delegate call to verify that at least one city has been selected to do that
    func testWeatherViewControllerHidesInitialSetupViewIfUserChoosesToAddCitiesForForecastsOnInitialSetUp() {
        loadViewControllerView()
        viewController!.initialSetupView.selectCitiesButton.sendActionsForControlEvents(.TouchUpInside)
        XCTAssertTrue(viewController!.initialSetupView.hidden)
    }
    
    // TODO: test that selecting "add favourite cities" on initial setup presents view controller for doing so
    // TODO: test that if the user is done adding cities "didSetupLocations" is set to true -> use delegate call to verify that at least one city has been selected to do that
    
    // MARK: Settings
    
    func testWeatherViewControllerPerformsSegueToSettingsScreenWhenUserTapsSettingsButton() {
        loadViewControllerView()
        expectationForNotification(BaseViewController.TestExtensionNotifications.DidAttemptSegue, object: viewController) { (notification) -> Bool in
            let userInfo = notification.userInfo as! [String : String]
            let segueIdentifier = userInfo[BaseViewController.TestExtensionNotificationsKeys.SegueIdentifier]
            return segueIdentifier == WeatherViewController.SegueIdentifiers.Settings
        }
        viewController!.settingsButton.sendActionsForControlEvents(.TouchUpInside)
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
    
    // MARK: Private
    
    func loadViewControllerView() {
        viewController!.beginAppearanceTransition(true, animated: false)
        viewController!.endAppearanceTransition()
    }
    
}

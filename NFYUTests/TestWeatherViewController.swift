//
//  TestWeatherViewController.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 01/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import XCTest
import CoreLocation
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
    
    func testWeatherViewControllerHasSettingsButtonHiddenByDefault() {
        loadViewControllerView()
        XCTAssertTrue(viewController!.settingsButton.hidden)
    }
    
    func testWeatherViewControllerShowsSettingsButtonIfLocationsAreSetUp() {
        viewController?.userDefaults?.didSetUpLocations = true
        loadViewControllerView()
        XCTAssertFalse(viewController!.settingsButton.hidden)
    }
    
    func testWeatherViewControllerShowsSettingsButtonIfLocationsGetSetUp() {
        loadViewControllerView()
        viewController?.didSetupLocations()
        XCTAssertFalse(viewController!.settingsButton.hidden)
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
    
    func testWeatherViewControllerPresentsSettingScreenWhenSelectCitiesButtonIsPressed() {
        loadViewControllerView()
        expectationForNotification(BaseViewController.TestExtensionNotifications.DidAttemptSegue, object: viewController) { [weak self] (notification) -> Bool in
            let segueIdentifier = notification.userInfo![BaseViewController.TestExtensionNotificationsKeys.SegueIdentifier] as! String
            let sender = notification.userInfo![BaseViewController.TestExtensionNotificationsKeys.SegueSender]
            return segueIdentifier == WeatherViewController.SegueIdentifiers.Settings && sender === self?.viewController?.initialSetupView
        }
        viewController!.initialSetupView.selectCitiesButton.sendActionsForControlEvents(.TouchUpInside)
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
    
    func testWeatherViewControllerAsksTheSettingScreenToPresentItselfWithOnlyTheCitiesOptionIfSenderIsInitialSetupView() {
        let segueIdentifier = WeatherViewController.SegueIdentifiers.Settings
        let settingsViewController = SettingsViewController()
        let navigationController = UINavigationController(rootViewController: settingsViewController) // as in storyboard
        let segue = UIStoryboardSegue(identifier: segueIdentifier, source: viewController!, destination: navigationController)
        viewController?.prepareForSegue(segue, sender: viewController?.initialSetupView)
        XCTAssertTrue(settingsViewController.displayOnlyFavouriteCities)
    }
    
    // MARK: Settings
    
    func testWeatherViewControllerSetsItselfAsSettingsViewControllerDelegateWhenPresentingItViaSegue() {
        let segueIdentifier = WeatherViewController.SegueIdentifiers.Settings
        let settingsViewController = SettingsViewController()
        let navigationController = UINavigationController(rootViewController: settingsViewController) // as in storyboard
        let segue = UIStoryboardSegue(identifier: segueIdentifier, source: viewController!, destination: navigationController)
        viewController?.prepareForSegue(segue, sender: viewController?.initialSetupView)
        XCTAssertTrue(settingsViewController.delegate === viewController)
    }
    
    func testWeatherViewControllerDoesNotHideInitialSetupViewWhenSettingsViewControllerIsDoneAndHasNoCitiesAndUserLocationIsDisabled() {
        loadViewControllerView()
        viewController?.settingsViewControllerDidFinish(SettingsViewController())
        XCTAssertFalse(viewController!.initialSetupView.hidden)
    }
    
    func testWeatherViewControllerHidesInitialSetupViewWhenSettingsScreenIsDoneAndHasCurrentLocation() {
        loadViewControllerView()
        viewController?.userDefaults?.canUseUserLocation = true
        viewController?.settingsViewControllerDidFinish(SettingsViewController())
        XCTAssertTrue(viewController!.initialSetupView.hidden)
    }
    
    func testWeatherViewControllerHidesInitialSetupViewWhenSettingsScreenIsDoneAndHasAtLeastOneCity() {
        loadViewControllerView()
        viewController?.userDefaults?.favouriteCities = [City(coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0), name: "", country: "")]
        viewController?.settingsViewControllerDidFinish(SettingsViewController())
        XCTAssertTrue(viewController!.initialSetupView.hidden)
    }
    
    func testWeatherViewControllerUpdatesUserDefaultsWhenSettingsViewControllerIsDoneIfHasNoCurrentLocationNorFavouriteCities() {
        loadViewControllerView()
        viewController?.settingsViewControllerDidFinish(SettingsViewController())
        XCTAssertFalse(viewController!.userDefaults!.didSetUpLocations)
    }
    
    func testWeatherViewControllerUpdatesShowsInitialSetupViewWhenSettingsViewControllerIsDoneIfHasNoCurrentLocationNorFavouriteCities() {
        loadViewControllerView()
        viewController?.settingsViewControllerDidFinish(SettingsViewController())
        XCTAssertFalse(viewController!.initialSetupView.hidden)
    }
    
    func testWeatherViewControllerUpdatesUserDefaultsWhenSettingsViewControllerIsDoneIfHasCurrentLocation() {
        loadViewControllerView()
        viewController?.userDefaults?.canUseUserLocation = true
        viewController?.settingsViewControllerDidFinish(SettingsViewController())
        XCTAssertTrue(viewController!.userDefaults!.didSetUpLocations)
    }
    
    func testWeatherViewControllerUpdatesUserDefaultsWhenSettingsViewControllerIsDoneIfHasAtLeastOneCity() {
        loadViewControllerView()
        viewController?.userDefaults?.favouriteCities = [City(coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0), name: "", country: "")]
        viewController?.settingsViewControllerDidFinish(SettingsViewController())
        XCTAssertTrue(viewController!.userDefaults!.didSetUpLocations)
    }
    
    func testWeatherViewControllerDoesNotDismissSettingsViewControllerWhenDoneIfHasNoCitiesAndUserLocationIsDisabled() {
        loadViewControllerView()
        let notificationName = BaseViewController.TestExtensionNotifications.DidAttemptDismissingViewController
        let observer = MockNotificationObserver(notificationName: notificationName, sender: viewController)
        viewController?.settingsViewControllerDidFinish(SettingsViewController())
        XCTAssertFalse(observer.didReceiveNotification)
    }
    
    func testWeatherViewControllerDismissesSettingsViewControllerWhenDoneIfHasCurrentLocation() {
        loadViewControllerView()
        let notificationName = BaseViewController.TestExtensionNotifications.DidAttemptDismissingViewController
        let observer = MockNotificationObserver(notificationName: notificationName, sender: viewController)
        viewController?.userDefaults?.canUseUserLocation = true
        viewController?.settingsViewControllerDidFinish(SettingsViewController())
        XCTAssertTrue(observer.didReceiveNotification)
    }
    
    func testWeatherViewControllerDismissesSettingsViewControllerWhenDoneIfHasAtLeastOneCity() {
        loadViewControllerView()
        let notificationName = BaseViewController.TestExtensionNotifications.DidAttemptDismissingViewController
        let observer = MockNotificationObserver(notificationName: notificationName, sender: viewController)
        viewController?.userDefaults?.favouriteCities = [City(coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0), name: "", country: "")]
        viewController?.settingsViewControllerDidFinish(SettingsViewController())
        XCTAssertTrue(observer.didReceiveNotification)
    }
    
    // TODO: test that if no favourite cities have been added and cannot use location viewController presents alert when settings try to get dismissed
    // TODO: note that the alert needs to differ depending on whether adding cities was the only option
    
    func testWeatherViewControllerPerformsSegueToSettingsScreenWhenUserTapsSettingsButton() {
        loadViewControllerView()
        expectationForNotification(BaseViewController.TestExtensionNotifications.DidAttemptSegue, object: viewController) { (notification) -> Bool in
            let segueIdentifier = notification.userInfo![BaseViewController.TestExtensionNotificationsKeys.SegueIdentifier] as! String
            return segueIdentifier == WeatherViewController.SegueIdentifiers.Settings
        }
        viewController!.settingsButton.sendActionsForControlEvents(.TouchUpInside)
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
    
    // MARK: Loading Forecasts
    
    // TODO: test that when scrolling to a location, the forecast for that location gets updated if not updated within the last hour
    // TODO: test that the forecast for the displayed location is updated when the app becomes active
    // TODO: test that current location is updated when app becomes active
    
    // MARK: Private
    
    func loadViewControllerView() {
        viewController!.beginAppearanceTransition(true, animated: false)
        viewController!.endAppearanceTransition()
    }
    
}

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
        viewController?.apiClient = FakeAPIClient()
    }
    
    override func tearDown() {
        viewController = nil
        super.tearDown()
    }
    
    func testViewControllerStopsObservingNotificationsWhenDeinitialized() {
        // ???: how to test this? Setting viewController to nil doesn't seem to call -deinit
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
    
    func testWeatherViewControllerShowsErrorMessageIfAfterInitialSetupTheUserHaChoosenToUseCurrentLocationButDisabledLocationServices() {
        let locationManager = viewController!.locationManager as! FakeLocationFinder
        locationManager.allowUseOfLocationServices = false
        loadViewControllerView()
        viewController!.initialSetupView.useLocationButton.sendActionsForControlEvents(.TouchUpInside)
        XCTAssertEqual(NSLocalizedString("USE_OF_LOCATION_SERVICES_NOT_AUTHORIZED", comment: ""), viewController!.backgroundMessageLabel.text)
    }
    
    func testWeatherViewControllerDoesNotShowErrorMessageIfLocationServicesAreDisabledButHasFavouriteCities() {
        let locationManager = viewController!.locationManager as! FakeLocationFinder
        locationManager.allowUseOfLocationServices = false
        viewController?.userDefaults?.favouriteLocations = [Location(coordinate: CLLocationCoordinate2D(), name: "", country: "")]
        loadViewControllerView()
        XCTAssertNil(viewController!.backgroundMessageLabel.text)
    }
    
    func testWeatherViewControllerShowsErrorMessageWhenAppBecomesActiveAndUserChangedPrivacySettingsForLocationServicesAndHasNoOtherLocation() {
        let locationManager = viewController!.locationManager as! FakeLocationFinder
        locationManager.allowUseOfLocationServices = true
        loadViewControllerView()
        locationManager.allowUseOfLocationServices = false
        NSNotificationCenter.defaultCenter().postNotificationName(UIApplicationDidBecomeActiveNotification, object: nil)
        XCTAssertEqual(NSLocalizedString("USE_OF_LOCATION_SERVICES_NOT_AUTHORIZED", comment: ""), viewController!.backgroundMessageLabel.text)
    }
    
    func testWeatherViewControllerReloadsUserLocationWhenAppBecomesActive() {
        let locationManager = viewController!.locationManager as! FakeLocationFinder
        locationManager.allowUseOfLocationServices = false
        loadViewControllerView()
        locationManager.allowUseOfLocationServices = true
        NSNotificationCenter.defaultCenter().postNotificationName(UIApplicationDidBecomeActiveNotification, object: nil)
        XCTAssertTrue(locationManager.didRequestCurrentLocation)
    }
    
    func testWeatherViewControllerDoesNotShowErrorMessageWhenAppBecomesActiveAndUserChangedPrivacySettingsForLocationServicesAndHasOtherCities() {
        let locationManager = viewController!.locationManager as! FakeLocationFinder
        locationManager.allowUseOfLocationServices = true
        viewController?.userDefaults?.favouriteLocations = [Location(coordinate: CLLocationCoordinate2D(), name: "", country: "")]
        loadViewControllerView()
        locationManager.allowUseOfLocationServices = false
        NSNotificationCenter.defaultCenter().postNotificationName(UIApplicationDidBecomeActiveNotification, object: nil)
        XCTAssertNil(viewController!.backgroundMessageLabel.text)
    }
    
    func testWeatherViewControllerRequestsUserLocationIfUserChoosesToUseItForForecastsOnInitialSetUp() {
        loadViewControllerView()
        viewController!.initialSetupView.useLocationButton.sendActionsForControlEvents(.TouchUpInside)
        let locationManager = viewController!.locationManager as! FakeLocationFinder
        XCTAssertTrue(locationManager.didRequestCurrentLocation)
    }
    
    func testWeatherViewControllerRequestsUserLocationWhenIsAboutToAppearOnScreenIfUserChoosedToUseItForForecasts() {
        let locationManager = viewController!.locationManager as! FakeLocationFinder
        locationManager.allowUseOfLocationServices = true
        loadViewControllerView()
        XCTAssertTrue(locationManager.didRequestCurrentLocation)
    }
    
    func testWeatherViewControllerDoesNotRequestUserLocationWhenIsAboutToAppearOnScreenIfUserChoosedNotToUseItForForecasts() {
        let locationManager = viewController!.locationManager as! FakeLocationFinder
        locationManager.allowUseOfLocationServices = false
        loadViewControllerView()
        XCTAssertFalse(locationManager.didRequestCurrentLocation)
    }
    
    func testWeatherViewControllerShowsLoadingIndicatorWhileLoadingLocation() {
        let locationManager = viewController!.locationManager as! FakeLocationFinder
        locationManager.allowUseOfLocationServices = true
        locationManager.shouldCallCompletionBlock = false
        loadViewControllerView()
        XCTAssertFalse(viewController!.activityIndicator.hidden)
        XCTAssertTrue(viewController!.activityIndicator!.isAnimating())
    }
    
    func testWeatherViewControllerHidesLoadingIndicatorAfterLocationHasBeenLoaded() {
        let locationManager = viewController!.locationManager as! FakeLocationFinder
        locationManager.allowUseOfLocationServices = true
        loadViewControllerView()
        XCTAssertTrue(viewController!.activityIndicator.hidden)
        XCTAssertFalse(viewController!.activityIndicator!.isAnimating())
    }
    
    func testWeatherViewControllerShowsLocalizedErrorMessageFromLocationManagerWhenRequestForLoadingCurrentLocationFails() {
        let locationManager = viewController!.locationManager as! FakeLocationFinder
        locationManager.allowUseOfLocationServices = true
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
    
    // MARK: Settings
    
    func testWeatherViewControllerSetsItselfAsSettingsViewControllerDelegateWhenPresentingItViaSegue() {
        let segueIdentifier = WeatherViewController.SegueIdentifiers.Settings
        let settingsViewController = SettingsViewController()
        let navigationController = UINavigationController(rootViewController: settingsViewController) // as in storyboard
        let segue = UIStoryboardSegue(identifier: segueIdentifier, source: viewController!, destination: navigationController)
        viewController?.prepareForSegue(segue, sender: viewController)
        XCTAssertTrue(settingsViewController.delegate === viewController)
    }
    
    func testWeatherViewControllerPassesUserDefaultsToSettingsViewControllerWhenPresentingItViaSegue() {
        let segueIdentifier = WeatherViewController.SegueIdentifiers.Settings
        let settingsViewController = SettingsViewController()
        let navigationController = UINavigationController(rootViewController: settingsViewController) // as in storyboard
        let segue = UIStoryboardSegue(identifier: segueIdentifier, source: viewController!, destination: navigationController)
        viewController?.prepareForSegue(segue, sender: viewController?.initialSetupView)
        XCTAssertTrue(settingsViewController.userDefaults === viewController?.userDefaults)
    }
    
    func testWeatherViewControllerDoesNotHideInitialSetupViewWhenSettingsViewControllerIsDoneAndHasNoCitiesAndUserLocationIsDisabled() {
        let locationManager = viewController!.locationManager as! FakeLocationFinder
        locationManager.allowUseOfLocationServices = false
        loadViewControllerView()
        viewController?.settingsViewControllerDidFinish(SettingsViewController())
        XCTAssertFalse(viewController!.initialSetupView.hidden)
    }
    
    func testWeatherViewControllerHidesInitialSetupViewWhenSettingsScreenIsDoneAndHasCurrentLocation() {
        loadViewControllerView()
        viewController?.settingsViewControllerDidFinish(SettingsViewController())
        XCTAssertTrue(viewController!.initialSetupView.hidden)
    }
    
    func testWeatherViewControllerHidesInitialSetupViewWhenSettingsScreenIsDoneAndHasAtLeastOneLocation() {
        loadViewControllerView()
        viewController?.userDefaults?.favouriteLocations = [Location(coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0), name: "", country: "")]
        viewController?.settingsViewControllerDidFinish(SettingsViewController())
        XCTAssertTrue(viewController!.initialSetupView.hidden)
    }
    
    func testWeatherViewControllerUpdatesUserDefaultsWhenSettingsViewControllerIsDoneIfHasNoCurrentLocationNorFavouriteCities() {
        let locationManager = viewController!.locationManager as! FakeLocationFinder
        locationManager.allowUseOfLocationServices = false
        loadViewControllerView()
        viewController?.settingsViewControllerDidFinish(SettingsViewController())
        XCTAssertFalse(viewController!.userDefaults!.didSetUpLocations)
    }
    
    func testWeatherViewControllerUpdatesShowsInitialSetupViewWhenSettingsViewControllerIsDoneIfHasNoCurrentLocationNorFavouriteCities() {
        viewController!.locationManager = nil // should be the same as setting stub to disable location services
        loadViewControllerView()
        viewController?.settingsViewControllerDidFinish(SettingsViewController())
        XCTAssertFalse(viewController!.initialSetupView.hidden)
    }
    
    func testWeatherViewControllerUpdatesUserDefaultsWhenSettingsViewControllerIsDoneIfHasCurrentLocation() {
        let locationManager = viewController!.locationManager as! FakeLocationFinder
        locationManager.allowUseOfLocationServices = true
        loadViewControllerView()
        viewController?.settingsViewControllerDidFinish(SettingsViewController())
        XCTAssertTrue(viewController!.userDefaults!.didSetUpLocations)
    }
    
    func testWeatherViewControllerUpdatesUserDefaultsWhenSettingsViewControllerIsDoneIfHasAtLeastOneLocation() {
        loadViewControllerView()
        viewController?.userDefaults?.favouriteLocations = [Location(coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0), name: "", country: "")]
        viewController?.settingsViewControllerDidFinish(SettingsViewController())
        XCTAssertTrue(viewController!.userDefaults!.didSetUpLocations)
    }
    
    func testWeatherViewControllerUpdatesLocationsWhenSettingsViewControllerIsDoneIfHasAtLeastOneLocation() {
        loadViewControllerView()
        viewController?.userDefaults?.favouriteLocations = [Location(coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0), name: "", country: "")]
        viewController?.settingsViewControllerDidFinish(SettingsViewController())
        XCTAssertEqual(viewController!.locations, viewController!.userDefaults!.favouriteLocations)
    }
    
    func testWeatherViewControllerUpdatesLocationsCorrectlyIfCurrentLocationWasAlreadyFoundWhenSettingsViewControllerIsDoneIfHasAtLeastOneLocation() {
        let locationManager = viewController!.locationManager as! FakeLocationFinder
        locationManager.stubLocation = CLLocation(latitude: 0.1234, longitude: 23.3456)
        loadViewControllerView()
        viewController?.userDefaults?.favouriteLocations = [Location(coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0), name: "", country: "")]
        viewController?.settingsViewControllerDidFinish(SettingsViewController())
        let currentLocation = Location(coordinate: locationManager.stubLocation!.coordinate)
        let expectedLocations = [currentLocation] + viewController!.userDefaults!.favouriteLocations
        XCTAssertEqual(viewController!.locations, expectedLocations)
    }
    
    func testWeatherViewControllerUpdatesLocationsCorrectlyIfCurrentLocationWasAlreadyFoundWhenReloadingUserLocation() {
        let locationManager = viewController!.locationManager as! FakeLocationFinder
        locationManager.stubLocation = CLLocation(latitude: 0.1234, longitude: 23.3456)
        viewController?.userDefaults?.favouriteLocations = [Location(coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0), name: "", country: "")]
        loadViewControllerView()
        locationManager.stubLocation = CLLocation(latitude: 0.2345, longitude: 32.5648)
        let currentLocation = Location(coordinate: locationManager.stubLocation!.coordinate)
        viewController?.updateCurrentLocationIfPossible()
        let expectedLocations = [currentLocation] + viewController!.userDefaults!.favouriteLocations
        XCTAssertEqual(viewController!.locations, expectedLocations)
    }
    
    func testWeatherViewControllerDoesNotDismissSettingsViewControllerWhenDoneIfHasNoCitiesAndUserLocationIsDisabled() {
        let locationManager = viewController!.locationManager as! FakeLocationFinder
        locationManager.allowUseOfLocationServices = false
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
        viewController?.settingsViewControllerDidFinish(SettingsViewController())
        XCTAssertTrue(observer.didReceiveNotification)
    }
    
    func testWeatherViewControllerDismissesSettingsViewControllerWhenDoneIfHasAtLeastOneLocation() {
        loadViewControllerView()
        let notificationName = BaseViewController.TestExtensionNotifications.DidAttemptDismissingViewController
        let observer = MockNotificationObserver(notificationName: notificationName, sender: viewController)
        viewController?.userDefaults?.favouriteLocations = [Location(coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0), name: "", country: "")]
        viewController?.settingsViewControllerDidFinish(SettingsViewController())
        XCTAssertTrue(observer.didReceiveNotification)
    }
    
    func testWeatherViewControllerPerformsSegueToSettingsScreenWhenUserTapsSettingsButton() {
        loadViewControllerView()
        expectationForNotification(BaseViewController.TestExtensionNotifications.DidAttemptSegue, object: viewController) { (notification) -> Bool in
            let segueIdentifier = notification.userInfo![BaseViewController.TestExtensionNotificationsKeys.SegueIdentifier] as! String
            return segueIdentifier == WeatherViewController.SegueIdentifiers.Settings
        }
        viewController!.settingsButton.sendActionsForControlEvents(.TouchUpInside)
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
    
    func testWeatherViewControllerReloadsDataOnCollectionViewWhenSettingsViewControllerIsDone() {
        // TODO: for MVP just reload everything... later on, perform only required changes
        loadViewControllerView()
        let fakeCollectionView = FakeCollectionView()
        viewController?.collectionView = fakeCollectionView
        viewController?.settingsViewControllerDidFinish(SettingsViewController())
        XCTAssertTrue(fakeCollectionView.didReloadData)
    }
    
    // MARK: Loading Forecasts
    
    func testWeatherViewControllerLoadsForecastsForUserLocationAfterFindingIt() {
        let locationManager = viewController!.locationManager as! FakeLocationFinder
        locationManager.stubLocation = CLLocation(latitude: 0.1234, longitude: 23.3456)
        let apiClient = viewController!.apiClient as! FakeAPIClient
        loadViewControllerView()
        XCTAssertEqual(locationManager.stubLocation?.coordinate, apiClient.lastRequestCoordinate)
    }
    
    func testWeatherViewControllerLoadsForecastsForFavouriteLocationsWhenTheViewIsLoaded() {
        let apiClient = viewController!.apiClient as! FakeAPIClient
        insertStubCitiesInUserDefaults()
        loadViewControllerView()
        let expectedRequestedCoordinates = viewController!.userDefaults!.favouriteLocations.map { (location) -> CLLocationCoordinate2D in
            return location.coordinate
        }
        XCTAssertEqual(expectedRequestedCoordinates, apiClient.requestedCoordinates)
    }
    
    func testWeatherViewControllerLoadsForecastsForFavouriteLocationsWhenAppBecomesActive() {
        insertStubCitiesInUserDefaults()
        loadViewControllerView()
        let expectedRequestedCoordinates = viewController!.userDefaults!.favouriteLocations.map { (location) -> CLLocationCoordinate2D in
            return location.coordinate
        }
        let apiClient = FakeAPIClient() // need new one for thest
        viewController?.apiClient = apiClient
        NSNotificationCenter.defaultCenter().postNotificationName(UIApplicationDidBecomeActiveNotification, object: nil)
        XCTAssertEqual(expectedRequestedCoordinates, apiClient.requestedCoordinates)
    }
    
    func testWeatherViewControllerUpdatesLocationWithForecastsAfterLoadingThem() {
        let testLocation = Location(coordinate: CLLocationCoordinate2D())
        viewController?.userDefaults?.favouriteLocations = [testLocation]
        let apiClient = viewController?.apiClient as? FakeAPIClient
        let forecast = Forecast(date: NSDate(), cityID: "cityID1", weather: .Clear, minTemperature: 0, maxTemperature: 0, currentTemperature: 0)
        apiClient?.stubForecasts = [forecast]
        loadViewControllerView()
        let location = viewController?.locations.first
        XCTAssertEqual(location!.forecasts, [forecast])
    }
    
    func testWeatherViewControllerReloadsLocationCollectionViewCellWhenForecastsAreLoaded() {
        let testLocation = Location(coordinate: CLLocationCoordinate2D())
        viewController?.userDefaults?.favouriteLocations = [testLocation]
        loadViewControllerView()
        let fakeCollectionView = FakeCollectionView()
        viewController!.collectionView = fakeCollectionView
        viewController!.fetchForecastsForLocation(viewController!.locations.first!)
        XCTAssertTrue(fakeCollectionView.didReloadData)
    }
    
    // MARK: UI
    
    func testWeatherViewControllersDisplaysCorrectNumberOfPages() {
        let testLocation = Location(coordinate: CLLocationCoordinate2D())
        let testLocation2 = Location(coordinate: CLLocationCoordinate2D())
        viewController?.userDefaults?.favouriteLocations = [testLocation, testLocation2]
        loadViewControllerView()
        XCTAssertEqual(2, viewController?.pageControl.numberOfPages)
    }
    
    // MARK: Helpers
    
    private func loadViewControllerView() {
        viewController!.beginAppearanceTransition(true, animated: false)
        viewController!.endAppearanceTransition()
    }
    
    private func insertStubCitiesInUserDefaults() {
        let london = Location(coordinate: CLLocationCoordinate2D(latitude: 51.5283063, longitude: -0.3824664), name: "London", country: "UK")
        let sf = Location(coordinate: CLLocationCoordinate2D(latitude: 37.7576792, longitude: -122.5078119), name: "San Francisco", country: "USA")
        viewController?.userDefaults?.favouriteLocations = [london, sf]
    }
    
}

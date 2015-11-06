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
    
    func testViewControllerCanBeCorrectlyInitialized() {
        XCTAssertNotNil(viewController)
    }
    
    func testViewControllerHasSetupViewHiddenByDefault() {
        viewController?.userDefaults = nil
        loadViewControllerView()
        XCTAssertFalse(viewController!.initialSetupView.hidden)
    }
    
    func testViewControllerHasSettingsButtonHiddenByDefault() {
        loadViewControllerView()
        XCTAssertTrue(viewController!.settingsButton.hidden)
    }
    
    func testViewControllerShowsSettingsButtonIfLocationsAreSetUp() {
        viewController?.userDefaults?.didSetUpLocations = true
        loadViewControllerView()
        XCTAssertFalse(viewController!.settingsButton.hidden)
    }
    
    func testViewControllerShowsSettingsButtonIfLocationsGetSetUp() {
        loadViewControllerView()
        viewController?.didSetupLocations()
        XCTAssertFalse(viewController!.settingsButton.hidden)
    }
    
    func testViewControllerHasActivityIndicatorHiddenByDefault() {
        loadViewControllerView()
        XCTAssertTrue(viewController!.activityIndicator.hidden)
    }
    
    func testViewControllerHasBackgroundMessageLabelHiddenByDefault() {
        loadViewControllerView()
        XCTAssertTrue(viewController!.backgroundMessageLabel.hidden)
    }
    
    func testViewControllerHasPageControlHiddenByDefault() {
        loadViewControllerView()
        XCTAssertTrue(viewController!.pageControl.hidden)
    }
    
    func testViewControllerShowsInitialSetUpViewIfUserDidNotYetSetUpLocations() {
        viewController!.userDefaults!.didSetUpLocations = false
        loadViewControllerView()
        XCTAssertFalse(viewController!.initialSetupView.hidden)
    }
    
    func testViewControllerHidesInitialSetUpViewIfUserDidAlreadySetUpLocations() {
        viewController!.userDefaults!.didSetUpLocations = true
        loadViewControllerView()
        XCTAssertTrue(viewController!.initialSetupView.hidden)
    }
    
    func testViewControllerHidesSettingsButtonWhenShowingInitialSetupView() {
        viewController!.userDefaults!.didSetUpLocations = false
        loadViewControllerView()
        XCTAssertTrue(viewController!.settingsButton.hidden)
    }
    
    func testViewControllerShowsSettingsButtonWhenNotShowingInitialSetupView() {
        viewController!.userDefaults!.didSetUpLocations = true
        loadViewControllerView()
        XCTAssertFalse(viewController!.settingsButton.hidden)
    }
    
    // MARK: Using Device Location
    
    func testViewControllerUpdatesUserDefaultsForHavingSetupLocationsIfUserChoosesToUseCurrentLocationForForecastsOnInitialSetUp() {
        loadViewControllerView()
        viewController!.initialSetupView.useLocationButton.sendActionsForControlEvents(.TouchUpInside)
        XCTAssertTrue(viewController!.userDefaults!.didSetUpLocations)
    }
    
    func testViewControllerHidesInitialSetupViewIfUserChoosesToUseCurrentLocationForForecastsOnInitialSetUp() {
        loadViewControllerView()
        viewController!.initialSetupView.useLocationButton.sendActionsForControlEvents(.TouchUpInside)
        XCTAssertTrue(viewController!.initialSetupView.hidden)
    }
    
    func testViewControllerShowsErrorMessageIfAfterInitialSetupTheUserHaChoosenToUseCurrentLocationButDisabledLocationServices() {
        let locationManager = viewController!.locationManager as! FakeLocationFinder
        locationManager.allowUseOfLocationServices = false
        loadViewControllerView()
        viewController!.initialSetupView.useLocationButton.sendActionsForControlEvents(.TouchUpInside)
        XCTAssertEqual(NSLocalizedString("USE_OF_LOCATION_SERVICES_NOT_AUTHORIZED", comment: ""), viewController!.backgroundMessageLabel.text)
    }
    
    func testViewControllerDoesNotShowErrorMessageIfLocationServicesAreDisabledButHasFavouriteCities() {
        let locationManager = viewController!.locationManager as! FakeLocationFinder
        locationManager.allowUseOfLocationServices = false
        viewController?.userDefaults?.favouriteLocations = [Location(coordinate: CLLocationCoordinate2D(), name: "", country: "")]
        loadViewControllerView()
        XCTAssertNil(viewController!.backgroundMessageLabel.text)
    }
    
    func testViewControllerShowsErrorMessageWhenAppBecomesActiveAndUserChangedPrivacySettingsForLocationServicesAndHasNoOtherLocation() {
        let locationManager = viewController!.locationManager as! FakeLocationFinder
        locationManager.allowUseOfLocationServices = true
        loadViewControllerView()
        locationManager.allowUseOfLocationServices = false
        NSNotificationCenter.defaultCenter().postNotificationName(UIApplicationDidBecomeActiveNotification, object: nil)
        XCTAssertEqual(NSLocalizedString("USE_OF_LOCATION_SERVICES_NOT_AUTHORIZED", comment: ""), viewController!.backgroundMessageLabel.text)
    }
    
    func testViewControllerReloadsUserLocationWhenAppBecomesActive() {
        let locationManager = viewController!.locationManager as! FakeLocationFinder
        locationManager.allowUseOfLocationServices = false
        loadViewControllerView()
        locationManager.allowUseOfLocationServices = true
        NSNotificationCenter.defaultCenter().postNotificationName(UIApplicationDidBecomeActiveNotification, object: nil)
        XCTAssertTrue(locationManager.didRequestCurrentLocation)
    }
    
    func testViewControllerDoesNotShowErrorMessageWhenAppBecomesActiveAndUserChangedPrivacySettingsForLocationServicesAndHasOtherCities() {
        let locationManager = viewController!.locationManager as! FakeLocationFinder
        locationManager.allowUseOfLocationServices = true
        viewController?.userDefaults?.favouriteLocations = [Location(coordinate: CLLocationCoordinate2D(), name: "", country: "")]
        loadViewControllerView()
        locationManager.allowUseOfLocationServices = false
        NSNotificationCenter.defaultCenter().postNotificationName(UIApplicationDidBecomeActiveNotification, object: nil)
        XCTAssertNil(viewController!.backgroundMessageLabel.text)
    }
    
    func testViewControllerRequestsUserLocationIfUserChoosesToUseItForForecastsOnInitialSetUp() {
        loadViewControllerView()
        viewController!.initialSetupView.useLocationButton.sendActionsForControlEvents(.TouchUpInside)
        let locationManager = viewController!.locationManager as! FakeLocationFinder
        XCTAssertTrue(locationManager.didRequestCurrentLocation)
    }
    
    func testViewControllerRequestsUserLocationWhenIsAboutToAppearOnScreenIfUserChoosedToUseItForForecasts() {
        let locationManager = viewController!.locationManager as! FakeLocationFinder
        locationManager.allowUseOfLocationServices = true
        loadViewControllerView()
        XCTAssertTrue(locationManager.didRequestCurrentLocation)
    }
    
    func testViewControllerDoesNotRequestUserLocationWhenIsAboutToAppearOnScreenIfUserChoosedNotToUseItForForecasts() {
        let locationManager = viewController!.locationManager as! FakeLocationFinder
        locationManager.allowUseOfLocationServices = false
        loadViewControllerView()
        XCTAssertFalse(locationManager.didRequestCurrentLocation)
    }
    
    func testViewControllerShowsLoadingIndicatorWhileLoadingLocation() {
        let locationManager = viewController!.locationManager as! FakeLocationFinder
        locationManager.allowUseOfLocationServices = true
        locationManager.shouldCallCompletionBlock = false
        loadViewControllerView()
        XCTAssertFalse(viewController!.activityIndicator.hidden)
        XCTAssertTrue(viewController!.activityIndicator!.isAnimating())
    }
    
    func testViewControllerHidesLoadingIndicatorAfterLocationHasBeenLoaded() {
        let locationManager = viewController!.locationManager as! FakeLocationFinder
        locationManager.allowUseOfLocationServices = true
        loadViewControllerView()
        XCTAssertTrue(viewController!.activityIndicator.hidden)
        XCTAssertFalse(viewController!.activityIndicator!.isAnimating())
    }
    
    func testViewControllerShowsLocalizedErrorMessageFromLocationManagerWhenRequestForLoadingCurrentLocationFails() {
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
    
    func testViewControllerPresentsSettingScreenWhenSelectCitiesButtonIsPressed() {
        loadViewControllerView()
        expectationForNotification(BaseViewController.TestExtensionNotifications.DidAttemptSegue, object: viewController) { [weak self] (notification) -> Bool in
            let segueIdentifier = notification.userInfo![BaseViewController.TestExtensionNotificationsKeys.SegueIdentifier] as! String
            let sender = notification.userInfo![BaseViewController.TestExtensionNotificationsKeys.SegueSender]
            return segueIdentifier == WeatherViewController.SegueIdentifiers.Settings.rawValue && sender === self?.viewController?.initialSetupView
        }
        viewController!.initialSetupView.selectCitiesButton.sendActionsForControlEvents(.TouchUpInside)
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
    
    // MARK: Settings
    
    func testViewControllerSetsItselfAsSettingsViewControllerDelegateWhenPresentingItViaSegue() {
        let segueIdentifier = WeatherViewController.SegueIdentifiers.Settings.rawValue
        let settingsViewController = SettingsViewController()
        let navigationController = UINavigationController(rootViewController: settingsViewController) // as in storyboard
        let segue = UIStoryboardSegue(identifier: segueIdentifier, source: viewController!, destination: navigationController)
        viewController?.prepareForSegue(segue, sender: viewController)
        XCTAssertTrue(settingsViewController.delegate === viewController)
    }
    
    func testViewControllerPassesUserDefaultsToSettingsViewControllerWhenPresentingItViaSegue() {
        let segueIdentifier = WeatherViewController.SegueIdentifiers.Settings.rawValue
        let settingsViewController = SettingsViewController()
        let navigationController = UINavigationController(rootViewController: settingsViewController) // as in storyboard
        let segue = UIStoryboardSegue(identifier: segueIdentifier, source: viewController!, destination: navigationController)
        viewController?.prepareForSegue(segue, sender: viewController?.initialSetupView)
        XCTAssertTrue(settingsViewController.userDefaults === viewController?.userDefaults)
    }
    
    func testViewControllerDoesNotHideInitialSetupViewWhenSettingsViewControllerIsDoneAndHasNoCitiesAndUserLocationIsDisabled() {
        let locationManager = viewController!.locationManager as! FakeLocationFinder
        locationManager.allowUseOfLocationServices = false
        loadViewControllerView()
        viewController?.settingsViewControllerDidFinish(SettingsViewController())
        XCTAssertFalse(viewController!.initialSetupView.hidden)
    }
    
    func testViewControllerHidesInitialSetupViewWhenSettingsScreenIsDoneAndHasCurrentLocation() {
        loadViewControllerView()
        viewController?.settingsViewControllerDidFinish(SettingsViewController())
        XCTAssertTrue(viewController!.initialSetupView.hidden)
    }
    
    func testViewControllerHidesInitialSetupViewWhenSettingsScreenIsDoneAndHasAtLeastOneLocation() {
        loadViewControllerView()
        viewController?.userDefaults?.favouriteLocations = [Location(coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0), name: "", country: "")]
        viewController?.settingsViewControllerDidFinish(SettingsViewController())
        XCTAssertTrue(viewController!.initialSetupView.hidden)
    }
    
    func testViewControllerUpdatesUserDefaultsWhenSettingsViewControllerIsDoneIfHasNoCurrentLocationNorFavouriteCities() {
        let locationManager = viewController!.locationManager as! FakeLocationFinder
        locationManager.allowUseOfLocationServices = false
        loadViewControllerView()
        viewController?.settingsViewControllerDidFinish(SettingsViewController())
        XCTAssertFalse(viewController!.userDefaults!.didSetUpLocations)
    }
    
    func testViewControllerUpdatesShowsInitialSetupViewWhenSettingsViewControllerIsDoneIfHasNoCurrentLocationNorFavouriteCities() {
        viewController!.locationManager = nil // should be the same as setting stub to disable location services
        loadViewControllerView()
        viewController?.settingsViewControllerDidFinish(SettingsViewController())
        XCTAssertFalse(viewController!.initialSetupView.hidden)
    }
    
    func testViewControllerUpdatesUserDefaultsWhenSettingsViewControllerIsDoneIfHasCurrentLocation() {
        let locationManager = viewController!.locationManager as! FakeLocationFinder
        locationManager.allowUseOfLocationServices = true
        loadViewControllerView()
        viewController?.settingsViewControllerDidFinish(SettingsViewController())
        XCTAssertTrue(viewController!.userDefaults!.didSetUpLocations)
    }
    
    func testViewControllerUpdatesUserDefaultsWhenSettingsViewControllerIsDoneIfHasAtLeastOneLocation() {
        loadViewControllerView()
        viewController?.userDefaults?.favouriteLocations = [Location(coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0), name: "", country: "")]
        viewController?.settingsViewControllerDidFinish(SettingsViewController())
        XCTAssertTrue(viewController!.userDefaults!.didSetUpLocations)
    }
    
    func testViewControllerUpdatesLocationsWhenSettingsViewControllerIsDoneIfHasAtLeastOneLocation() {
        loadViewControllerView()
        viewController?.userDefaults?.favouriteLocations = [Location(coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0), name: "", country: "")]
        viewController?.settingsViewControllerDidFinish(SettingsViewController())
        XCTAssertEqual(viewController!.locations, viewController!.userDefaults!.favouriteLocations)
    }
    
    func testViewControllerUpdatesLocationsCorrectlyIfCurrentLocationWasAlreadyFoundWhenSettingsViewControllerIsDoneIfHasAtLeastOneLocation() {
        let locationManager = viewController!.locationManager as! FakeLocationFinder
        locationManager.stubLocation = CLLocation(latitude: 0.1234, longitude: 23.3456)
        loadViewControllerView()
        viewController?.userDefaults?.favouriteLocations = [Location(coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0), name: "", country: "")]
        viewController?.settingsViewControllerDidFinish(SettingsViewController())
        let currentLocation = Location(coordinate: locationManager.stubLocation!.coordinate)
        let expectedLocations = [currentLocation] + viewController!.userDefaults!.favouriteLocations
        XCTAssertEqual(viewController!.locations, expectedLocations)
    }
    
    func testViewControllerUpdatesLocationsCorrectlyIfCurrentLocationWasAlreadyFoundWhenReloadingUserLocation() {
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
    
    func testViewControllerDoesNotDismissSettingsViewControllerWhenDoneIfHasNoCitiesAndUserLocationIsDisabled() {
        let locationManager = viewController!.locationManager as! FakeLocationFinder
        locationManager.allowUseOfLocationServices = false
        loadViewControllerView()
        let notificationName = BaseViewController.TestExtensionNotifications.DidAttemptDismissingViewController
        let observer = MockNotificationObserver(notificationName: notificationName, sender: viewController)
        viewController?.settingsViewControllerDidFinish(SettingsViewController())
        XCTAssertFalse(observer.didReceiveNotification)
    }
    
    func testViewControllerDismissesSettingsViewControllerWhenDoneIfHasCurrentLocation() {
        loadViewControllerView()
        let notificationName = BaseViewController.TestExtensionNotifications.DidAttemptDismissingViewController
        let observer = MockNotificationObserver(notificationName: notificationName, sender: viewController)
        viewController?.settingsViewControllerDidFinish(SettingsViewController())
        XCTAssertTrue(observer.didReceiveNotification)
    }
    
    func testViewControllerDismissesSettingsViewControllerWhenDoneIfHasAtLeastOneLocation() {
        loadViewControllerView()
        let notificationName = BaseViewController.TestExtensionNotifications.DidAttemptDismissingViewController
        let observer = MockNotificationObserver(notificationName: notificationName, sender: viewController)
        viewController?.userDefaults?.favouriteLocations = [Location(coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0), name: "", country: "")]
        viewController?.settingsViewControllerDidFinish(SettingsViewController())
        XCTAssertTrue(observer.didReceiveNotification)
    }
    
    func testViewControllerPerformsSegueToSettingsScreenWhenUserTapsSettingsButton() {
        loadViewControllerView()
        expectationForNotification(BaseViewController.TestExtensionNotifications.DidAttemptSegue, object: viewController) { (notification) -> Bool in
            let segueIdentifier = notification.userInfo![BaseViewController.TestExtensionNotificationsKeys.SegueIdentifier] as! String
            return segueIdentifier == WeatherViewController.SegueIdentifiers.Settings.rawValue
        }
        viewController!.settingsButton.sendActionsForControlEvents(.TouchUpInside)
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
    
    func testViewControllerReloadsDataOnCollectionViewWhenSettingsViewControllerIsDone() {
        // TODO: for MVP just reload everything... later on, perform only required changes
        loadViewControllerView()
        let fakeCollectionView = FakeCollectionView()
        viewController?.collectionView = fakeCollectionView
        viewController?.settingsViewControllerDidFinish(SettingsViewController())
        XCTAssertTrue(fakeCollectionView.didReloadData)
    }
    
    // MARK: Loading Forecasts
    
    func testViewControllerLoadsForecastsForUserLocationAfterFindingIt() {
        let locationManager = viewController!.locationManager as! FakeLocationFinder
        locationManager.stubLocation = CLLocation(latitude: 0.1234, longitude: 23.3456)
        let apiClient = viewController!.apiClient as! FakeAPIClient
        loadViewControllerView()
        XCTAssertEqual(locationManager.stubLocation?.coordinate, apiClient.lastRequestCoordinate)
    }
    
    func testViewControllerLoadsForecastsForFavouriteLocationsWhenTheViewIsLoaded() {
        let apiClient = viewController!.apiClient as! FakeAPIClient
        insertStubCitiesInUserDefaults()
        loadViewControllerView()
        let expectedRequestedCoordinates = viewController!.userDefaults!.favouriteLocations.map { (location) -> CLLocationCoordinate2D in
            return location.coordinate
        }
        XCTAssertEqual(expectedRequestedCoordinates, apiClient.requestedCoordinates)
    }
    
    func testViewControllerLoadsForecastsForFavouriteLocationsWhenAppBecomesActive() {
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
    
    func testViewControllerUpdatesLocationWithForecastsAfterLoadingThem() {
        let testLocation = Location(coordinate: CLLocationCoordinate2D())
        viewController?.userDefaults?.favouriteLocations = [testLocation]
        let apiClient = viewController?.apiClient as? FakeAPIClient
        let forecast = Forecast(date: NSDate(), cityID: "cityID1", weather: .Clear, minTemperature: 0, maxTemperature: 0, currentTemperature: 0)
        apiClient?.stubForecasts = [forecast]
        loadViewControllerView()
        let location = viewController?.locations.first
        XCTAssertEqual(location!.forecasts, [forecast])
    }
    
    func testViewControllerReloadsLocationCollectionViewCellWhenForecastsAreLoaded() {
        let testLocation = Location(coordinate: CLLocationCoordinate2D())
        viewController?.userDefaults?.favouriteLocations = [testLocation]
        loadViewControllerView()
        let fakeCollectionView = FakeCollectionView()
        viewController!.collectionView = fakeCollectionView
        viewController!.fetchForecastsForLocation(viewController!.locations.first!)
        XCTAssertTrue(fakeCollectionView.didReloadData)
    }
    
    // MARK: - UI
    // MARK: Page Control
    
    func testViewControllersDisplaysCorrectNumberOfPagesWhenLocationServicesAreDisabled() {
        let locationManager = viewController!.locationManager as! FakeLocationFinder
        locationManager.allowUseOfLocationServices = false
        let testLocation = Location(coordinate: CLLocationCoordinate2D())
        let testLocation2 = Location(coordinate: CLLocationCoordinate2D())
        viewController?.userDefaults?.favouriteLocations = [testLocation, testLocation2]
        loadViewControllerView()
        XCTAssertEqual(2, viewController?.pageControl.numberOfPages)
    }
    
    func testViewControllersDisplaysCorrectNumberOfPagesWhenLocationServicesAreEnabled() {
        let locationManager = viewController!.locationManager as! FakeLocationFinder
        locationManager.allowUseOfLocationServices = true
        let testLocation = Location(coordinate: CLLocationCoordinate2D())
        let testLocation2 = Location(coordinate: CLLocationCoordinate2D())
        viewController?.userDefaults?.favouriteLocations = [testLocation, testLocation2]
        loadViewControllerView()
        XCTAssertEqual(3, viewController?.pageControl.numberOfPages)
    }
    
    // MARK: Collection View
    
    func testViewControllerIsCollectionViewDataSource() {
        loadViewControllerView()
        let dataSource = viewController?.collectionView.dataSource
        XCTAssertTrue(viewController === dataSource)
    }
    
    func testViewControllerAlwaysHasAtLeastOneCollectionViewSection() {
        let numberOfSections = viewController?.numberOfSectionsInCollectionView(FakeCollectionView())
        XCTAssertEqual(1, numberOfSections)
    }
    
    func testViewControllersDisplaysCorrectNumberOfCollectionViewCellsWhenLocationServicesAreDisabled() {
        let locationManager = viewController!.locationManager as! FakeLocationFinder
        locationManager.allowUseOfLocationServices = false
        let testLocation = Location(coordinate: CLLocationCoordinate2D())
        let testLocation2 = Location(coordinate: CLLocationCoordinate2D())
        viewController?.userDefaults?.favouriteLocations = [testLocation, testLocation2]
        loadViewControllerView()
        let numberOfCells = viewController?.collectionView(viewController!.collectionView, numberOfItemsInSection: 0)
        XCTAssertEqual(2, numberOfCells)
    }
    
    func testViewControllersDisplaysCorrectNumberOfCollectionViewCellsWhenLocationServicesAreEnabled() {
        let locationManager = viewController!.locationManager as! FakeLocationFinder
        locationManager.allowUseOfLocationServices = true
        let testLocation = Location(coordinate: CLLocationCoordinate2D())
        let testLocation2 = Location(coordinate: CLLocationCoordinate2D())
        viewController?.userDefaults?.favouriteLocations = [testLocation, testLocation2]
        loadViewControllerView()
        let numberOfCells = viewController?.collectionView(viewController!.collectionView, numberOfItemsInSection: 0)
        XCTAssertEqual(3, numberOfCells)
    }
    
    func testViewControllerIsCollectionViewFlowLayoutDelegate() {
        let theViewController = viewController as? UICollectionViewDelegateFlowLayout
        XCTAssertNotNil(theViewController)
    }
    
    func testViewControllerDisplaysCollectionViewWithFlowLayoutWithHorizontalScrollingOption() {
        loadViewControllerView()
        let layout = viewController?.collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        XCTAssertEqual(UICollectionViewScrollDirection.Horizontal, layout?.scrollDirection)
    }
    
    func testViewControllerDisplaysCollectionViewWithFlowLayoutWithNoSpaceBetweenCells() {
        loadViewControllerView()
        let layout = viewController?.collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        XCTAssertEqual(0, layout?.minimumInteritemSpacing)
        XCTAssertEqual(0, layout?.minimumLineSpacing)
    }
    
    func testViewControllerDisplaysCollectionViewWithFlowLayoutWithNoSectionMargins() {
        loadViewControllerView()
        let layout = viewController?.collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        XCTAssertEqual(UIEdgeInsetsZero, layout?.sectionInset)
    }
    
    func testViewControllerCollectionViewIsPaginated() {
        loadViewControllerView()
        XCTAssertTrue(viewController!.collectionView!.pagingEnabled)
    }
    
    func testViewControllerCollectionDoesNotShowScrollingIndicators() {
        loadViewControllerView()
        XCTAssertFalse(viewController!.collectionView!.showsVerticalScrollIndicator)
        XCTAssertFalse(viewController!.collectionView!.showsHorizontalScrollIndicator)
    }
    
    func testViewControllerDisplaysEachCollectionViewCellWithSameSizeAsTheCollectionViewItselfForPaginationPurposesAndHoldAllContent() {
        loadViewControllerView()
        let collectionView = viewController?.collectionView
        let layout = collectionView?.collectionViewLayout
        let indexPath = NSIndexPath(forItem: 0, inSection: 0)
        let cellSize = viewController?.collectionView(collectionView!, layout: layout!, sizeForItemAtIndexPath: indexPath)
        XCTAssertEqual(collectionView?.bounds.size, cellSize)
    }
    
    func testViewControllerUpdatesPageControllerCurrentPageWhenUserMovesBetweenCities() {
        let testLocation = Location(coordinate: CLLocationCoordinate2D())
        let testLocation2 = Location(coordinate: CLLocationCoordinate2D())
        viewController?.userDefaults?.favouriteLocations = [testLocation, testLocation2]
        loadViewControllerView()
        viewController?.collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 0), atScrollPosition: .CenteredHorizontally, animated: false)
        viewController?.scrollViewDidEndDecelerating(viewController!.collectionView) // need to manually call this as it relates to actual user interactions
        XCTAssertEqual(1, viewController?.pageControl.currentPage)
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

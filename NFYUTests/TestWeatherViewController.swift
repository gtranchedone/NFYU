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
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        viewController = storyboard.instantiateInitialViewController() as? WeatherViewController
        viewController?.locationManager = FakeUserLocationManager()
        viewController?.userDefaults = FakeUserDefaults()
        viewController?.apiClient = FakeAPIClient()
        viewController?.userDefaults?.didSetUpLocations = true // unless otherwise specified in the test
    }
    
    override func tearDown() {
        viewController = nil
        super.tearDown()
    }
    
    func testViewControllerStopsObservingNotificationsWhenDeinitialized() {
        // ???: how to test this? Setting viewController to nil doesn't seem to call -deinit
    }
    
    // MARK: - Initial UI State
    
    func testViewControllerCanBeCorrectlyInitialized() {
        XCTAssertNotNil(viewController)
    }
    
    func testViewControllerHasSetupViewHiddenByDefault() {
        viewController?.userDefaults = nil
        loadViewControllerView()
        XCTAssertFalse(viewController!.initialSetupView.isHidden)
    }
    
    func testViewControllerHasSettingsButtonHiddenIfLocationsAreNotSetUp() {
        viewController?.userDefaults?.didSetUpLocations = false
        loadViewControllerView()
        XCTAssertTrue(viewController!.settingsButton.isHidden)
    }
    
    func testViewControllerShowsSettingsButtonIfLocationsAreSetUp() {
        viewController?.userDefaults?.didSetUpLocations = true
        loadViewControllerView()
        XCTAssertFalse(viewController!.settingsButton.isHidden)
    }
    
    func testViewControllerShowsSettingsButtonIfLocationsGetSetUp() {
        loadViewControllerView()
        viewController?.didSetupLocations()
        XCTAssertFalse(viewController!.settingsButton.isHidden)
    }
    
    func testViewControllerHasActivityIndicatorHiddenByDefault() {
        loadViewControllerView()
        XCTAssertTrue(viewController!.activityIndicator.isHidden)
    }
    
    func testViewControllerHasBackgroundMessageLabelHiddenByDefault() {
        loadViewControllerView()
        XCTAssertTrue(viewController!.backgroundMessageLabel.isHidden)
    }
    
    func testViewControllerHasPageControlHiddenByDefault() {
        loadViewControllerView()
        XCTAssertTrue(viewController!.pageControl.isHidden)
    }
    
    func testViewControllerShowsInitialSetUpViewIfUserDidNotYetSetUpLocations() {
        viewController!.userDefaults!.didSetUpLocations = false
        loadViewControllerView()
        XCTAssertFalse(viewController!.initialSetupView.isHidden)
    }
    
    func testViewControllerHidesInitialSetUpViewIfUserDidAlreadySetUpLocations() {
        viewController!.userDefaults!.didSetUpLocations = true
        loadViewControllerView()
        XCTAssertTrue(viewController!.initialSetupView.isHidden)
    }
    
    func testViewControllerHidesSettingsButtonWhenShowingInitialSetupView() {
        viewController!.userDefaults!.didSetUpLocations = false
        loadViewControllerView()
        XCTAssertTrue(viewController!.settingsButton.isHidden)
    }
    
    func testViewControllerShowsSettingsButtonWhenNotShowingInitialSetupView() {
        viewController!.userDefaults!.didSetUpLocations = true
        loadViewControllerView()
        XCTAssertFalse(viewController!.settingsButton.isHidden)
    }
    
    // MARK: - Using Device Location
    
    func testViewControllerDoesNotTryToLoadUserLocationIfLocationsHaveNotBeenSetUp() {
        viewController?.userDefaults?.didSetUpLocations = false
        loadViewControllerView()
        let locationManager = viewController?.locationManager as! FakeUserLocationManager
        XCTAssertFalse(locationManager.didRequestCurrentLocation)
    }
    
    func testViewControllerUpdatesUserDefaultsForHavingSetupLocationsIfUserChoosesToUseCurrentLocationForForecastsOnInitialSetUp() {
        loadViewControllerView()
        viewController!.initialSetupView.useLocationButton.sendActions(for: .touchUpInside)
        XCTAssertTrue(viewController!.userDefaults!.didSetUpLocations)
    }
    
    func testViewControllerRequestsLocationPermissionsIfUserChoosesToUseCurrentLocationForForecastsOnInitialSetUp() {
        loadViewControllerView()
        viewController!.initialSetupView.useLocationButton.sendActions(for: .touchUpInside)
        XCTAssertTrue(viewController!.locationManager!.didRequestAuthorization)
    }
    
    func testViewControllerHidesInitialSetupViewIfUserChoosesToUseCurrentLocationForForecastsOnInitialSetUp() {
        loadViewControllerView()
        viewController!.initialSetupView.useLocationButton.sendActions(for: .touchUpInside)
        XCTAssertTrue(viewController!.initialSetupView.isHidden)
    }
    
    func testViewControllerShowsErrorMessageIfAfterInitialSetupTheUserHaChoosenToUseCurrentLocationButDisabledLocationServices() {
        disableLocationServices()
        loadViewControllerView()
        viewController!.initialSetupView.useLocationButton.sendActions(for: .touchUpInside)
        XCTAssertEqual(NSLocalizedString("USE_OF_LOCATION_SERVICES_NOT_AUTHORIZED", comment: ""), viewController!.backgroundMessageLabel.text)
    }
    
    func testViewControllerDoesNotShowErrorMessageIfLocationServicesAreDisabledButHasFavouriteCities() {
        disableLocationServices()
        insertStubCitiesInUserDefaults()
        loadViewControllerView()
        XCTAssertNil(viewController!.backgroundMessageLabel.text)
    }
    
    func testViewControllerShowsErrorMessageWhenAppBecomesActiveAndUserChangedPrivacySettingsForLocationServicesAndHasNoOtherLocation() {
        let locationManager = viewController!.locationManager as! FakeUserLocationManager
        locationManager.allowUseOfLocationServices = true
        loadViewControllerView()
        locationManager.allowUseOfLocationServices = false
        NotificationCenter.default.post(name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        XCTAssertEqual(NSLocalizedString("USE_OF_LOCATION_SERVICES_NOT_AUTHORIZED", comment: ""), viewController!.backgroundMessageLabel.text)
    }
    
    func testViewControllerReloadsUserLocationWhenAppBecomesActive() {
        let locationManager = viewController!.locationManager as! FakeUserLocationManager
        locationManager.allowUseOfLocationServices = false
        loadViewControllerView()
        locationManager.allowUseOfLocationServices = true
        NotificationCenter.default.post(name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        XCTAssertTrue(locationManager.didRequestCurrentLocation)
    }
    
    func testViewControllerDoesNotShowErrorMessageWhenAppBecomesActiveAndUserChangedPrivacySettingsForLocationServicesAndHasOtherCities() {
        let locationManager = viewController!.locationManager as! FakeUserLocationManager
        locationManager.allowUseOfLocationServices = true
        viewController?.userDefaults?.favouriteLocations = [Location(coordinate: CLLocationCoordinate2D(), name: "", country: "")]
        loadViewControllerView()
        locationManager.allowUseOfLocationServices = false
        NotificationCenter.default.post(name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        XCTAssertNil(viewController!.backgroundMessageLabel.text)
    }
    
    func testViewControllerRequestsUserLocationIfUserChoosesToUseItForForecastsOnInitialSetUp() {
        enableLocationServices()
        loadViewControllerView()
        viewController!.initialSetupView.useLocationButton.sendActions(for: .touchUpInside)
        let locationManager = viewController!.locationManager as! FakeUserLocationManager
        XCTAssertTrue(locationManager.didRequestCurrentLocation)
    }
    
    func testViewControllerRequestsUserLocationWhenIsAboutToAppearOnScreenIfUserChoosedToUseItForForecasts() {
        enableLocationServices()
        loadViewControllerView()
        let locationManager = viewController!.locationManager as! FakeUserLocationManager
        XCTAssertTrue(locationManager.didRequestCurrentLocation)
    }
    
    func testViewControllerDoesNotRequestUserLocationWhenIsAboutToAppearOnScreenIfUserChoosedNotToUseItForForecasts() {
        disableLocationServices()
        loadViewControllerView()
        let locationManager = viewController!.locationManager as! FakeUserLocationManager
        XCTAssertFalse(locationManager.didRequestCurrentLocation)
    }
    
    func testViewControllerShowsLoadingIndicatorWhileLoadingLocation() {
        enableLocationServices()
        let locationManager = viewController!.locationManager as! FakeUserLocationManager
        locationManager.shouldCallCompletionBlock = false
        loadViewControllerView()
        XCTAssertFalse(viewController!.activityIndicator.isHidden)
        XCTAssertTrue(viewController!.activityIndicator!.isAnimating)
    }
    
    func testViewControllerHidesLoadingIndicatorAfterLocationHasBeenLoaded() {
        disableLocationServices() // to prevent default behaviour
        loadViewControllerView() // load the view to test against it later
        let location = enableLocationServicesAndStubLocation()
        let expectation = self.expectation(description: "Expect location fetch to complete")
        viewController?.fetchForecastsForLocation(location) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
        XCTAssertTrue(viewController!.activityIndicator.isHidden)
        XCTAssertFalse(viewController!.activityIndicator!.isAnimating)
    }
    
    func testViewControllerShowsLocalizedErrorMessageFromLocationManagerWhenRequestForLoadingCurrentLocationFails() {
        enableLocationServices()
        let expectedErrorMessage = "Some error message"
        let stubUserInfo = [NSLocalizedDescriptionKey: expectedErrorMessage]
        let locationManager = viewController!.locationManager as! FakeUserLocationManager
        locationManager.stubResult = .error(NSError(domain: "test", code: 400, userInfo: stubUserInfo))
        loadViewControllerView()
        XCTAssertFalse(viewController!.backgroundMessageLabel.isHidden)
        XCTAssertEqual(expectedErrorMessage, viewController!.backgroundMessageLabel.text)
    }
    
    // MARK: - Selecting Cities
    
    func testViewControllerPresentsSettingScreenWhenSelectCitiesButtonIsPressed() {
        loadViewControllerView()
        let notificationName = TestExtensionNotifications.DidAttemptSegue
        expectation(forNotification: notificationName, object: viewController) { [weak self] (notification) -> Bool in
            let segueIdentifier = notification.userInfo![TestExtensionNotificationsKeys.SegueIdentifier] as! String
            let sender = notification.userInfo![TestExtensionNotificationsKeys.SegueSender] as? NSObject
            return segueIdentifier == WeatherViewController.SegueIdentifiers.Settings.rawValue && sender === self?.viewController?.initialSetupView
        }
        viewController!.initialSetupView.selectCitiesButton.sendActions(for: .touchUpInside)
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testViewControllerShowsSettingButtonWhenSelectCitiesButtonIsPressed() {
        viewController?.userDefaults?.didSetUpLocations = false
        loadViewControllerView()
        viewController!.initialSetupView.selectCitiesButton.sendActions(for: .touchUpInside)
        XCTAssertFalse(viewController!.settingsButton.isHidden)
    }
    
    // MARK: - Settings
    
    func testViewControllerSetsItselfAsSettingsViewControllerDelegateWhenPresentingItViaSegue() {
        let segueIdentifier = WeatherViewController.SegueIdentifiers.Settings.rawValue
        let settingsViewController = SettingsViewController()
        let navigationController = UINavigationController(rootViewController: settingsViewController) // as in storyboard
        let segue = UIStoryboardSegue(identifier: segueIdentifier, source: viewController!, destination: navigationController)
        viewController?.prepare(for: segue, sender: viewController)
        XCTAssertTrue(settingsViewController.delegate === viewController)
    }
    
    func testViewControllerPassesUserDefaultsToSettingsViewControllerWhenPresentingItViaSegue() {
        let segueIdentifier = WeatherViewController.SegueIdentifiers.Settings.rawValue
        let settingsViewController = SettingsViewController()
        let navigationController = UINavigationController(rootViewController: settingsViewController) // as in storyboard
        let segue = UIStoryboardSegue(identifier: segueIdentifier, source: viewController!, destination: navigationController)
        viewController?.prepare(for: segue, sender: viewController)
        XCTAssertTrue(settingsViewController.delegate === viewController)
    }
    
    func testViewControllerPassesLocationManagerToSettingsViewControllerWhenPresentingItViaSegue() {
        let segueIdentifier = WeatherViewController.SegueIdentifiers.Settings.rawValue
        let settingsViewController = SettingsViewController()
        let navigationController = UINavigationController(rootViewController: settingsViewController) // as in storyboard
        let segue = UIStoryboardSegue(identifier: segueIdentifier, source: viewController!, destination: navigationController)
        viewController?.prepare(for: segue, sender: viewController?.initialSetupView)
        XCTAssertTrue(settingsViewController.locationManager === viewController?.locationManager)
    }
    
    func testViewControllerDoesNotHideInitialSetupViewWhenSettingsViewControllerIsDoneAndHasNoCitiesAndUserLocationIsDisabled() {
        viewController?.userDefaults?.didSetUpLocations = false
        disableLocationServices()
        loadViewControllerView()
        viewController?.settingsViewControllerDidFinish(SettingsViewController())
        XCTAssertFalse(viewController!.initialSetupView.isHidden)
    }
    
    func testViewControllerHidesInitialSetupViewWhenSettingsScreenIsDoneAndHasCurrentLocation() {
        loadViewControllerView()
        viewController?.settingsViewControllerDidFinish(SettingsViewController())
        XCTAssertTrue(viewController!.initialSetupView.isHidden)
    }
    
    func testViewControllerHidesInitialSetupViewWhenSettingsScreenIsDoneAndHasAtLeastOneLocation() {
        loadViewControllerView()
        insertStubCitiesInUserDefaults()
        viewController?.settingsViewControllerDidFinish(SettingsViewController())
        XCTAssertTrue(viewController!.initialSetupView.isHidden)
    }
    
    func testViewControllerUpdatesUserDefaultsWhenSettingsViewControllerIsDoneIfHasNoCurrentLocationNorFavouriteCities() {
        let locationManager = viewController!.locationManager as! FakeUserLocationManager
        locationManager.allowUseOfLocationServices = false
        loadViewControllerView()
        viewController?.settingsViewControllerDidFinish(SettingsViewController())
        XCTAssertFalse(viewController!.userDefaults!.didSetUpLocations)
    }
    
    func testViewControllerUpdatesShowsInitialSetupViewWhenSettingsViewControllerIsDoneIfHasNoCurrentLocationNorFavouriteCities() {
        viewController?.userDefaults?.didSetUpLocations = false
        viewController!.locationManager = nil // should be the same as setting stub to disable location services
        loadViewControllerView()
        viewController?.settingsViewControllerDidFinish(SettingsViewController())
        XCTAssertFalse(viewController!.initialSetupView.isHidden)
    }
    
    func testViewControllerUpdatesUserDefaultsWhenSettingsViewControllerIsDoneIfHasCurrentLocation() {
        let locationManager = viewController!.locationManager as! FakeUserLocationManager
        locationManager.allowUseOfLocationServices = true
        loadViewControllerView()
        viewController?.settingsViewControllerDidFinish(SettingsViewController())
        XCTAssertTrue(viewController!.userDefaults!.didSetUpLocations)
    }
    
    func testViewControllerUpdatesUserDefaultsWhenSettingsViewControllerIsDoneIfHasAtLeastOneLocation() {
        loadViewControllerView()
        insertStubCitiesInUserDefaults()
        viewController?.settingsViewControllerDidFinish(SettingsViewController())
        XCTAssertTrue(viewController!.userDefaults!.didSetUpLocations)
    }
    
    func testViewControllerUpdatesLocationsWhenSettingsViewControllerIsDoneIfHasAtLeastOneLocation() {
        disableLocationServices()
        loadViewControllerView()
        let stubLocations = [Location(coordinate: CLLocationCoordinate2D(), name: "", country: "")]
        viewController?.userDefaults?.favouriteLocations = stubLocations
        viewController?.settingsViewControllerDidFinish(SettingsViewController())
        XCTAssertEqual(viewController!.locations, viewController!.userDefaults!.favouriteLocations)
    }
    
    func testViewControllerUpdatesLocationsCorrectlyIfCurrentLocationWasAlreadyFoundWhenSettingsViewControllerIsDoneIfHasAtLeastOneLocation() {
        enableLocationServices()
        let location = enableLocationServicesAndStubLocation()
        insertStubCitiesInUserDefaults()
        loadViewControllerView()
        viewController?.settingsViewControllerDidFinish(SettingsViewController())
        let expectedLocations = [location] + viewController!.userDefaults!.favouriteLocations
        XCTAssertEqual(viewController!.locations, expectedLocations)
    }
    
    func testViewControllerUpdatesLocationsCorrectlyIfCurrentLocationWasAlreadyFoundWhenReloadingUserLocation() {
        let _ = enableLocationServicesAndStubLocation()
        insertStubCitiesInUserDefaults()
        loadViewControllerView()
        let otherLocation = Location(latitude: 0.2345, longitude: 32.5648)
        let locationManager = viewController!.locationManager as! FakeUserLocationManager
        locationManager.stubResult = .success(otherLocation)
        viewController?.updateCurrentLocationIfPossible()
        let expectedLocations = [otherLocation] + viewController!.userDefaults!.favouriteLocations
        XCTAssertEqual(viewController!.locations, expectedLocations)
    }
    
    func testViewControllerDoesNotDismissSettingsViewControllerWhenDoneIfHasNoCitiesAndUserLocationIsDisabled() {
        let locationManager = viewController!.locationManager as! FakeUserLocationManager
        locationManager.allowUseOfLocationServices = false
        loadViewControllerView()
        let notificationName = TestExtensionNotifications.DidAttemptDismissingViewController
        let observer = MockNotificationObserver(notificationName: notificationName, sender: viewController)
        viewController?.settingsViewControllerDidFinish(SettingsViewController())
        XCTAssertFalse(observer.didReceiveNotification)
    }
    
    func testViewControllerDismissesSettingsViewControllerWhenDoneIfHasCurrentLocation() {
        enableLocationServices()
        loadViewControllerView()
        let notificationName = TestExtensionNotifications.DidAttemptDismissingViewController
        let observer = MockNotificationObserver(notificationName: notificationName, sender: viewController)
        viewController?.settingsViewControllerDidFinish(SettingsViewController())
        XCTAssertTrue(observer.didReceiveNotification)
    }
    
    func testViewControllerDismissesSettingsViewControllerWhenDoneIfHasAtLeastOneLocation() {
        loadViewControllerView()
        let notificationName = TestExtensionNotifications.DidAttemptDismissingViewController
        let observer = MockNotificationObserver(notificationName: notificationName, sender: viewController)
        viewController?.userDefaults?.favouriteLocations = [Location(coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0), name: "", country: "")]
        viewController?.settingsViewControllerDidFinish(SettingsViewController())
        XCTAssertTrue(observer.didReceiveNotification)
    }
    
    func testViewControllerPerformsSegueToSettingsScreenWhenUserTapsSettingsButton() {
        loadViewControllerView()
        expectation(forNotification: TestExtensionNotifications.DidAttemptSegue, object: viewController) { (notification) -> Bool in
            let segueIdentifier = notification.userInfo![TestExtensionNotificationsKeys.SegueIdentifier] as! String
            return segueIdentifier == WeatherViewController.SegueIdentifiers.Settings.rawValue
        }
        viewController!.settingsButton.sendActions(for: .touchUpInside)
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testViewControllerReloadsDataOnCollectionViewWhenSettingsViewControllerIsDone() {
        // for MVP just reload everything... later on, perform only required changes
        loadViewControllerView()
        let fakeCollectionView = FakeCollectionView()
        viewController?.collectionView = fakeCollectionView
        viewController?.settingsViewControllerDidFinish(SettingsViewController())
        XCTAssertTrue(fakeCollectionView.didReloadData)
    }
    
    // MARK: - Loading Forecasts
    
    func testViewControllerDoesNotLoadForecastsForUserLocationIfCoordinatesWereNotLoaded() {
        let apiClient = viewController!.apiClient as! FakeAPIClient
        loadViewControllerView()
        XCTAssertNil(apiClient.lastRequestCoordinate)
    }
    
    func testViewControllerLoadsForecastsForUserLocationAfterFindingIt() {
        let location = enableLocationServicesAndStubLocation()
        let apiClient = viewController!.apiClient as! FakeAPIClient
        loadViewControllerView()
        XCTAssertEqual(location.coordinate, apiClient.lastRequestCoordinate)
    }
    
    func testViewControllerLoadsForecastsForFavouriteLocationsWhenTheViewIsLoaded() {
        let apiClient = viewController!.apiClient as! FakeAPIClient
        insertStubCitiesInUserDefaults()
        disableLocationServices()
        loadViewControllerView()
        let expectedRequestedCoordinates = viewController!.userDefaults!.favouriteLocations.map { (location) -> CLLocationCoordinate2D in
            return location.coordinate
        }
        XCTAssertEqual(expectedRequestedCoordinates, apiClient.requestedCoordinates)
    }
    
    func testViewControllerLoadsForecastsForFavouriteLocationsWhenAppBecomesActive() {
        insertStubCitiesInUserDefaults()
        disableLocationServices()
        loadViewControllerView()
        let expectedRequestedCoordinates = viewController!.userDefaults!.favouriteLocations.map { (location) -> CLLocationCoordinate2D in
            return location.coordinate
        }
        let apiClient = FakeAPIClient() // need new one for thest
        viewController?.apiClient = apiClient
        NotificationCenter.default.post(name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        XCTAssertEqual(expectedRequestedCoordinates, apiClient.requestedCoordinates)
    }
    
    func testViewControllerUpdatesLocationWithForecastsAfterLoadingThem() {
        disableLocationServices()
        let testLocation = Location(coordinate: CLLocationCoordinate2D())
        viewController?.userDefaults?.favouriteLocations = [testLocation]
        let stubForecasts = stubAPIReturnedForecasts()
        loadViewControllerView()
        let location = viewController?.locations.first
        XCTAssertEqual(location!.forecasts, stubForecasts)
    }
    
    func testViewControllerReloadsCollectionViewDataWhenForecastsAreLoadedAndHadNoSectionsBefore() {
        let testLocation = Location(coordinate: CLLocationCoordinate2D())
        viewController?.userDefaults?.favouriteLocations = [testLocation]
        disableLocationServices()
        loadViewControllerView()
        stubAPIReturnedForecasts()
        let fakeCollectionView = FakeCollectionView()
        viewController!.collectionView = fakeCollectionView
        viewController!.fetchForecastsForLocation(viewController!.locations.first!)
        XCTAssertTrue(fakeCollectionView.didReloadData)
    }
    
    // MARK: - UI Tests
    // MARK: Page Control
    
    func testViewControllersDisplaysCorrectNumberOfPagesWhenLocationServicesAreDisabled() {
        disableLocationServices()
        insertStubCitiesInUserDefaults()
        loadViewControllerView()
        XCTAssertEqual(2, viewController?.pageControl.numberOfPages)
    }
    
    func testViewControllersDisplaysCorrectNumberOfPagesWhenLocationServicesAreEnabled() {
        let locationManager = viewController!.locationManager as! FakeUserLocationManager
        locationManager.allowUseOfLocationServices = true
        insertStubCitiesInUserDefaults()
        loadViewControllerView()
        XCTAssertEqual(3, viewController?.pageControl.numberOfPages)
    }
    
    // MARK: Collection View
    
    func testViewControllerIsCollectionViewDataSource() {
        loadViewControllerView()
        let dataSource = viewController?.collectionView.dataSource
        XCTAssertTrue(viewController === dataSource)
    }
    
    func testViewControllerDisplaysZeroCollectionViewCellsIfLocationsHaveNotBeenSetUp() {
        viewController?.userDefaults?.didSetUpLocations = false
        let numberOfSections = viewController?.numberOfSections(in: FakeCollectionView())
        XCTAssertEqual(0, numberOfSections)
    }
    
    func testViewControllerAlwaysHasOneCollectionViewSectionAfterLocationHaveBeenSetUp() {
        viewController?.userDefaults?.didSetUpLocations = true
        let numberOfSections = viewController?.numberOfSections(in: FakeCollectionView())
        XCTAssertEqual(1, numberOfSections)
    }
    
    func testViewControllersDisplaysCorrectNumberOfCollectionViewCellsWhenLocationServicesAreDisabled() {
        disableLocationServices()
        insertStubCitiesInUserDefaults()
        loadViewControllerView()
        let numberOfCells = viewController?.collectionView(viewController!.collectionView, numberOfItemsInSection: 0)
        XCTAssertEqual(2, numberOfCells)
    }
    
    func testViewControllersDisplaysCorrectNumberOfCollectionViewCellsWhenLocationServicesAreEnabled() {
        enableLocationServices()
        insertStubCitiesInUserDefaults()
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
        XCTAssertEqual(UICollectionViewScrollDirection.horizontal, layout?.scrollDirection)
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
        XCTAssertEqual(UIEdgeInsets.zero, layout?.sectionInset)
    }
    
    func testViewControllerCollectionViewIsPaginated() {
        loadViewControllerView()
        XCTAssertTrue(viewController!.collectionView!.isPagingEnabled)
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
        let indexPath = IndexPath(item: 0, section: 0)
        let cellSize = viewController?.collectionView(collectionView!, layout: layout!, sizeForItemAt: indexPath)
        XCTAssertEqual(collectionView?.bounds.size, cellSize)
    }
    
    func testViewControllerUpdatesPageControllerCurrentPageWhenUserMovesBetweenCities() {
        let testLocation = Location(coordinate: CLLocationCoordinate2D())
        let testLocation2 = Location(coordinate: CLLocationCoordinate2D())
        viewController?.userDefaults?.favouriteLocations = [testLocation, testLocation2]
        loadViewControllerView()
        let indexPath = IndexPath(item: 1, section: 0)
        viewController?.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        viewController?.scrollViewDidEndDecelerating(viewController!.collectionView) // need to manually call this as it relates to actual user interactions
        XCTAssertEqual(1, viewController?.pageControl.currentPage)
    }
    
    // MARK: Forecasts Cells
    
    func testViewControllerDisplaysTemplateForecastWhileLoadingForecast() {
        viewController?.apiClient = nil
        disableLocationServices()
        insertStubCitiesInUserDefaults()
        loadViewControllerView()
        let indexPath = IndexPath(item: 0, section: 0)
        let cell = viewController?.collectionView(viewController!.collectionView, cellForItemAt: indexPath) as? LocationCollectionViewCell
        XCTAssertEqual("London", cell?.locationNameLabel.text)
        XCTAssertEqual("-", cell?.weatherConditionLabel.text)
        XCTAssertEqual("-º", cell?.currentTemperatureLabel.text)
        XCTAssertEqual("", cell?.hourlyTodayConditionsLabel.text)
    }
    
    func testViewControllerDisplaysForecastInformationWhenAvailable() {
        viewController?.apiClient = nil
        disableLocationServices()
        insertStubCitiesInUserDefaults()
        loadViewControllerView()
        addStubForecastsToCities()
        viewController?.collectionView.reloadData()
        let indexPath = IndexPath(item: 0, section: 0)
        let cell = viewController?.collectionView(viewController!.collectionView, cellForItemAt: indexPath) as? LocationCollectionViewCell
        XCTAssertEqual("London", cell?.locationNameLabel.text)
        XCTAssertEqual("Rain", cell?.weatherConditionLabel.text)
        XCTAssertEqual("16ºC", cell?.currentTemperatureLabel.text)
        XCTAssertEqual("9:00 AM: Rain", cell?.hourlyTodayConditionsLabel.text)
    }
    
    func testViewControllerDisplaysForecastInformationWhenAvailableUsingFahrenheitDegreesIfNeeded() {
        viewController?.userDefaults?.useFahrenheitDegrees = true
        viewController?.apiClient = nil
        disableLocationServices()
        insertStubCitiesInUserDefaults()
        loadViewControllerView()
        addStubForecastsToCities()
        viewController?.collectionView.reloadData()
        let indexPath = IndexPath(item: 0, section: 0)
        let cell = viewController?.collectionView(viewController!.collectionView, cellForItemAt: indexPath) as? LocationCollectionViewCell
        XCTAssertEqual("London", cell?.locationNameLabel.text)
        XCTAssertEqual("Rain", cell?.weatherConditionLabel.text)
        XCTAssertEqual("61ºF", cell?.currentTemperatureLabel.text)
        XCTAssertEqual("9:00 AM: Rain", cell?.hourlyTodayConditionsLabel.text)
    }
    
    func testViewControllerDisplaysTemplateForecastWhileLoadingUserLocation() {
        enableLocationServices()
        viewController?.apiClient = nil
        loadViewControllerView()
        let indexPath = IndexPath(item: 0, section: 0)
        let cell = viewController?.collectionView(viewController!.collectionView, cellForItemAt: indexPath) as? LocationCollectionViewCell
        XCTAssertEqual("-", cell?.locationNameLabel.text)
        XCTAssertEqual("-", cell?.weatherConditionLabel.text)
        XCTAssertEqual("-º", cell?.currentTemperatureLabel.text)
        XCTAssertEqual("", cell?.hourlyTodayConditionsLabel.text)
    }
    
    func testViewControllerDisplaysTemplateForecastAfterUserLocationHasBeenLoaded() {
        enableLocationServices()
        let locationManager = viewController?.locationManager as? FakeUserLocationManager
        locationManager?.stubResult = .success(Location(latitude: 1.0, longitude: 1.0))
        let apiClient = viewController?.apiClient as? FakeAPIClient
        apiClient?.stubLocationInfo = LocationInfo(id: "123", name: "Naples", city: "Naples", country: "Italy")
        loadViewControllerView()
        let indexPath = IndexPath(item: 0, section: 0)
        let cell = viewController?.collectionView(viewController!.collectionView, cellForItemAt: indexPath) as? LocationCollectionViewCell
        XCTAssertEqual("Naples", cell?.locationNameLabel.text)
        XCTAssertEqual("-", cell?.weatherConditionLabel.text)
        XCTAssertEqual("-º", cell?.currentTemperatureLabel.text)
    }
    
    func testViewControllerDoesNotCrashAppWhenMovingFromPageToPageIfLocationIsEnabled() {
        enableLocationServices()
        insertStubCitiesInUserDefaults()
        loadViewControllerView()
        let currentLocationIndexPath = IndexPath(item: 1, section: 0)
        viewController?.collectionView.scrollToItem(at: currentLocationIndexPath, at: .centeredHorizontally, animated: false)
        let firstCityIndexPath = IndexPath(item: 1, section: 0)
        viewController?.collectionView.scrollToItem(at: firstCityIndexPath, at: .centeredHorizontally, animated: false)
        let lastCityIndexPath = IndexPath(item: 2, section: 0)
        viewController?.collectionView.scrollToItem(at: lastCityIndexPath, at: .centeredHorizontally, animated: false)
        // NOTE: no need for assertions: if the app crashes the test will fail
    }
    
}

extension TestWeatherViewController {
    
    fileprivate func loadViewControllerView() {
        viewController!.beginAppearanceTransition(true, animated: false)
        viewController!.endAppearanceTransition()
    }
    
    fileprivate func enableLocationServices() {
        let locationManager = viewController?.locationManager as? FakeUserLocationManager
        locationManager?.allowUseOfLocationServices = true
    }
    
    fileprivate func disableLocationServices() {
        let locationManager = viewController?.locationManager as? FakeUserLocationManager
        locationManager?.allowUseOfLocationServices = false
    }
    
    fileprivate func enableLocationServicesAndStubLocation() -> Location {
        enableLocationServices()
        let locationManager = viewController!.locationManager as! FakeUserLocationManager
        let location = Location(latitude: 0.1234, longitude: 23.3456)
        locationManager.stubResult = .success(location)
        return location
    }
    
    @discardableResult fileprivate func stubAPIReturnedForecasts() -> [Forecast] {
        let apiClient = viewController?.apiClient as? FakeAPIClient
        let forecast = Forecast(date: Date(), cityID: "cityID1", weather: .Clear, minTemperature: 0, maxTemperature: 0, currentTemperature: 0)
        let stubForecasts = [forecast]
        apiClient?.stubForecasts = stubForecasts
        return stubForecasts
    }
    
    fileprivate func insertStubCitiesInUserDefaults() {
        let london = Location(coordinate: CLLocationCoordinate2D(latitude: 51.5283063, longitude: -0.3824664), name: "London", country: "GB")
        let sf = Location(coordinate: CLLocationCoordinate2D(latitude: 37.7576792, longitude: -122.5078119), name: "San Francisco", country: "USA")
        viewController?.userDefaults?.favouriteLocations = [london, sf]
    }
    
    fileprivate func addStubForecastsToCities() {
        let calendar = Calendar.current
        var components = (calendar as NSCalendar).components([.day, .month, .year, .hour], from: Date())
        components.hour = 9
        let todayAtNine = calendar.date(from: components)!
        let london = viewController?.locations.first
        london?.forecasts = [Forecast(date: todayAtNine, cityID: "123", weather: .Rain, minTemperature: 15, maxTemperature: 17, currentTemperature: 16)]
        let sf = viewController?.locations.last
        sf?.forecasts = [Forecast(date: todayAtNine, cityID: "234", weather: .Mist, minTemperature: 17, maxTemperature: 19, currentTemperature: 18)]
    }
    
}

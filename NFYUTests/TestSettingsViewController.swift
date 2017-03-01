//
//  TestSettingsViewController.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 04/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import XCTest
import CoreLocation
@testable import NFYU

class FakeSettingsViewControllerDelegate: SettingsViewControllerDelegate {
    
    fileprivate(set) var didFinish = false
    
    func settingsViewControllerDidFinish(_ viewController: SettingsViewController) {
        didFinish = true
    }
    
}

class TestSettingsViewController: XCTestCase {

    var viewController: SettingsViewController?
    
    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        viewController = storyboard.instantiateViewController(withIdentifier: "SettingsViewController") as? SettingsViewController
        viewController?.userDefaults = FakeUserDefaults()
    }
    
    override func tearDown() {
        viewController = nil
        super.tearDown()
    }
    
    // MARK: Initial Setup

    func testViewControllerIsCorrectlyInitializedByStoryboard() {
        XCTAssertNotNil(viewController)
    }
    
    func testViewControllerTitleIsCorrectlySet() {
        loadViewControllerView()
        XCTAssertEqual(NSLocalizedString("SETTINGS_TITLE", comment: ""), viewController?.title)
    }
    
    func testViewControllerShowsDoneButtonInNavigationBarInOrderToGetDismissed() {
        loadViewControllerView()
        XCTAssertEqual(UIBarButtonItemStyle.done, viewController?.navigationItem.rightBarButtonItem?.style)
    }
    
    func testViewControllerTellsDelegateThatItHasFinishedWhenUserTapsDoneButtonInNavigationBar() {
        loadViewControllerView()
        let fakeDelegate = FakeSettingsViewControllerDelegate()
        viewController?.delegate = fakeDelegate
        let button = viewController?.navigationItem.rightBarButtonItem
        let _ = button?.target?.perform(button!.action)
        XCTAssertTrue(fakeDelegate.didFinish)
    }
    
    // MARK: - UITableViewDelegate
    // MARK: Cities Display Logic
    
    func testSettingsViewControllerAlwaysHasTwoSectionsInTableViewToBeAbleToAddCitiesAndSelectOtherSettings() {
        // section 1 will be dedicated to user settings and section 2 to the favourite cities
        loadViewControllerView()
        let numberOfSections = viewController!.numberOfSections(in: viewController!.tableView)
        XCTAssertEqual(2, numberOfSections)
    }
    
    func testSettingsViewControllerHasTwoRowsInFirstSectionForChangingDeviceLocationUsageAndTemperatureUnit() {
        loadViewControllerView()
        let numberOfRows = viewController!.tableView(viewController!.tableView!, numberOfRowsInSection: 0)
        XCTAssertEqual(2, numberOfRows)
    }
    
    func testSettingsViewControllerHasOneRowToAddCitiesIfUserHasNoFavouriteCities() {
        loadViewControllerView()
        let numberOfRows = viewController!.tableView(viewController!.tableView!, numberOfRowsInSection: 1)
        XCTAssertEqual(1, numberOfRows)
    }
    
    func testSettingsViewControllerHasOneRowToAddCitiesIfUserHasNoFavouriteCitiesAndNoUserDefaults() {
        viewController?.userDefaults = nil
        loadViewControllerView()
        let numberOfRows = viewController!.tableView(viewController!.tableView!, numberOfRowsInSection: 1)
        XCTAssertEqual(1, numberOfRows)
    }
    
    func testSettingsViewControllerHasTwoRowsInFirstSectionForChangingDeviceLocationAndChangingUnitsUsageEvenWhenUserHasSavedFavouriteLocations() {
        insertStubCitiesInUserDefaults()
        loadViewControllerView()
        let numberOfRows = viewController!.tableView(viewController!.tableView!, numberOfRowsInSection: 0)
        XCTAssertEqual(2, numberOfRows)
    }
    
    func testSettingsViewControllerDisplaysRowForEnablingOrDisablingUserLocationUsage() {
        loadViewControllerView()
        let tableView = viewController!.tableView
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = viewController!.tableView(tableView!, cellForRowAt: indexPath) as? SwitchTableViewCell
        XCTAssertTrue(cell!.switchControl.isKind(of: UISwitch.self))
        XCTAssertEqual(UITableViewCellSelectionStyle.none, cell!.selectionStyle)
        XCTAssertEqual(NSLocalizedString("TOGGLE_USER_LOCATION_ENABLED", comment: ""), cell?.textLabel?.text)
    }
    
    func testSettingsViewControllerDisplaysRowForEnablingOrDisablingUserLocationUsageWithSwitchOnIfLocationServicesAreEnabled() {
        viewController?.locationManager = FakeUserLocationManager()
        allowLocationServices()
        loadViewControllerView()
        let tableView = viewController!.tableView
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = viewController!.tableView(tableView!, cellForRowAt: indexPath) as? SwitchTableViewCell
        XCTAssertTrue(cell!.switchControl.isOn)
    }
    
    func testSettingsViewControllerDisplaysRowForEnablingOrDisablingUserLocationUsageWithSwitchOffIfLocationServicesAreDisabled() {
        viewController?.locationManager = FakeUserLocationManager()
        disallowLocationServices()
        loadViewControllerView()
        let tableView = viewController!.tableView
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = viewController!.tableView(tableView!, cellForRowAt: indexPath) as? SwitchTableViewCell
        XCTAssertFalse(cell!.switchControl.isOn)
    }
    
    func testSettingsViewControllerDisplaysRowForEnablingOrDisablingUserLocationUsageWithSwitchOffIfLocationManagerIsNil() {
        loadViewControllerView()
        let tableView = viewController!.tableView
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = viewController!.tableView(tableView!, cellForRowAt: indexPath) as? SwitchTableViewCell
        XCTAssertFalse(cell!.switchControl.isOn)
    }
    
    func testSettingsViewControllerShowsAlertWithInstructionsOnHowToDisableUserLocationIfUserTriesToSwitchOffLocationServices() {
        viewController?.locationManager = FakeUserLocationManager()
        allowLocationServices()
        loadViewControllerView()
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = viewController!.tableView.cellForRow(at: indexPath) as? SwitchTableViewCell
        cell?.switchControl.isOn = false
        let notificationName = TestExtensionNotifications.DidAttemptPresentingViewController
        expectation(forNotification: notificationName, object: viewController) { (notification) -> Bool in
            let controllerKey = TestExtensionNotificationsKeys.PresentedViewController
            let alert = notification.userInfo?[controllerKey] as? UIAlertController
            let didShowExpectedTitle = alert?.title == NSLocalizedString("INSTRUCTIONS_FOR_DISABLING_USE_OF_DEVICE_LOCATION_ALERT_TITLE", comment: "")
            let didShowExpectedMessage = alert?.message == NSLocalizedString("INSTRUCTIONS_FOR_DISABLING_USE_OF_DEVICE_LOCATION_ALERT_MESSAGE", comment: "")
            return didShowExpectedTitle && didShowExpectedMessage
        }
        cell?.switchControl.sendActions(for: .valueChanged)
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testSettingsViewControllerShowsAlertWithInstructionsOnHowToEnableUserLocationIfUserTriesToSwitchOnLocationServicesAfterTheyHaveBeenDisabled() {
        let locationManager = FakeUserLocationManager()
        locationManager.stubDidRequestPermissions = false
        viewController?.locationManager = locationManager
        loadViewControllerView()
        disallowLocationServices()
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = viewController!.tableView.cellForRow(at: indexPath) as? SwitchTableViewCell
        cell?.switchControl.isOn = true
        let notificationName = TestExtensionNotifications.DidAttemptPresentingViewController
        expectation(forNotification: notificationName, object: viewController) { (notification) -> Bool in
            let controllerKey = TestExtensionNotificationsKeys.PresentedViewController
            let alert = notification.userInfo?[controllerKey] as? UIAlertController
            let didShowExpectedTitle = alert?.title == NSLocalizedString("INSTRUCTIONS_FOR_ENABLING_USE_OF_DEVICE_LOCATION_ALERT_TITLE", comment: "")
            let didShowExpectedMessage = alert?.message == NSLocalizedString("INSTRUCTIONS_FOR_ENABLING_USE_OF_DEVICE_LOCATION_ALERT_MESSAGE", comment: "")
            return didShowExpectedTitle && didShowExpectedMessage
        }
        cell?.switchControl.sendActions(for: .valueChanged)
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testSettingsViewControllerAsksForLocationUsagePermissionsIfUserWasNotPromptedForItYet() {
        let locationManager = FakeUserLocationManager()
        locationManager.stubDidRequestPermissions = true
        viewController?.locationManager = locationManager
        loadViewControllerView()
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = viewController!.tableView.cellForRow(at: indexPath) as? SwitchTableViewCell
        cell?.switchControl.isOn = true
        cell?.switchControl.sendActions(for: .valueChanged)
        XCTAssertTrue(locationManager.didRequestPermissions)
    }
    
    func testSettingsViewControllerHasOneRowForEachFavouriteLocationPlusOneForAddingNewCities() {
        insertStubCitiesInUserDefaults()
        loadViewControllerView()
        let numberOfRows = viewController!.tableView(viewController!.tableView!, numberOfRowsInSection: 1)
        XCTAssertEqual(3, numberOfRows)
    }
    
    func testSettingsViewControllerDisplaysTheRightRowForAddingCitiesWhenNoOtherLocationIsPresent() {
        loadViewControllerView()
        let tableView = viewController!.tableView
        let indexPath = IndexPath(row: 0, section: 1)
        let cell = viewController!.tableView(tableView!, cellForRowAt: indexPath)
        XCTAssertEqual(UITableViewCellSelectionStyle.default, cell.selectionStyle)
        XCTAssertEqual(UITableViewCellAccessoryType.disclosureIndicator, cell.accessoryType)
        XCTAssertEqual(NSLocalizedString("ADD_CITY_CELL_TITLE", comment: ""), cell.textLabel?.text)
    }
    
    func testSettingsViewControllerDisplaysTheRightRowForAddingCitiesWhenOtherCitiesArePresent() {
        loadViewControllerView()
        insertStubCitiesInUserDefaults()
        let tableView = viewController!.tableView
        let indexPath0 = IndexPath(row: 0, section: 1)
        let cell0 = viewController!.tableView(tableView!, cellForRowAt: indexPath0)
        XCTAssertEqual(UITableViewCellAccessoryType.disclosureIndicator, cell0.accessoryType)
        XCTAssertEqual(NSLocalizedString("ADD_CITY_CELL_TITLE", comment: ""), cell0.textLabel?.text)
        XCTAssertEqual(UITableViewCellSelectionStyle.default, cell0.selectionStyle)
        
        let indexPath1 = IndexPath(row: 1, section: 1)
        let cell1 = viewController!.tableView(tableView!, cellForRowAt: indexPath1)
        XCTAssertEqual(UITableViewCellSelectionStyle.none, cell1.selectionStyle)
        XCTAssertEqual(UITableViewCellAccessoryType.none, cell1.accessoryType)
        XCTAssertEqual("London, UK", cell1.textLabel?.text)
        
        let indexPath2 = IndexPath(row: 2, section: 1)
        let cell2 = viewController!.tableView(tableView!, cellForRowAt: indexPath2)
        XCTAssertEqual(UITableViewCellSelectionStyle.none, cell2.selectionStyle)
        XCTAssertEqual(UITableViewCellAccessoryType.none, cell2.accessoryType)
        XCTAssertEqual("San Francisco, CA", cell2.textLabel?.text)
    }
    
    func testSettingsViewControllerDisplaysRowForChangingDefaultTemperatureUnit() {
        loadViewControllerView()
        let tableView = viewController!.tableView
        let indexPath = IndexPath(row: 1, section: 0)
        let cell = viewController!.tableView(tableView!, cellForRowAt: indexPath) as? SwitchTableViewCell
        XCTAssertTrue(cell!.switchControl.isKind(of: UISwitch.self))
        XCTAssertEqual(UITableViewCellSelectionStyle.none, cell!.selectionStyle)
        XCTAssertEqual(NSLocalizedString("USE_FAHRENHEIT_DEGREES", comment: ""), cell?.textLabel?.text)
    }
    
    func testSettingsViewControllerDisplaysRowForEnablingOrDisablingUseOfFahrenheitDegreesWithSwitchOffBasedOnUserDefaults() {
        viewController?.userDefaults?.useFahrenheitDegrees = false
        loadViewControllerView()
        let tableView = viewController!.tableView
        let indexPath = IndexPath(row: 1, section: 0)
        let cell = viewController!.tableView(tableView!, cellForRowAt: indexPath) as? SwitchTableViewCell
        XCTAssertFalse(cell!.switchControl.isOn)
    }
    
    func testSettingsViewControllerDisplaysRowForEnablingOrDisablingUseOfFahrenheitDegreesWithSwitchOnBasedOnUserDefaults() {
        viewController?.userDefaults?.useFahrenheitDegrees = true
        loadViewControllerView()
        let tableView = viewController!.tableView
        let indexPath = IndexPath(row: 1, section: 0)
        let cell = viewController!.tableView(tableView!, cellForRowAt: indexPath) as? SwitchTableViewCell
        XCTAssertTrue(cell!.switchControl.isOn)
    }
    
    func testSettingsViewControllerSavesUserSettingsWhenUserDecidesToUseFahrenheitDegrees() {
        viewController?.userDefaults?.useFahrenheitDegrees = false
        loadViewControllerView()
        let indexPath = IndexPath(row: 1, section: 0)
        let cell = viewController!.tableView.cellForRow(at: indexPath) as? SwitchTableViewCell
        cell!.switchControl.isOn = true
        cell!.switchControl.sendActions(for: .valueChanged)
        XCTAssertTrue(viewController!.userDefaults!.useFahrenheitDegrees)
    }
    
    func testSettingsViewControllerSavesUserSettingsWhenUserDecidesNotToUseFahrenheitDegrees() {
        viewController?.userDefaults?.useFahrenheitDegrees = true
        loadViewControllerView()
        let indexPath = IndexPath(row: 1, section: 0)
        let cell = viewController!.tableView.cellForRow(at: indexPath) as? SwitchTableViewCell
        cell!.switchControl.isOn = false
        cell!.switchControl.sendActions(for: .valueChanged)
        XCTAssertFalse(viewController!.userDefaults!.useFahrenheitDegrees)
    }
    
    // MARK: - UITableViewDelegate
    // MARK: Cities Deletion
    
    func testSettingsViewControllerHasEditButtonInNavigationBarWhenPresent() {
        loadViewControllerView()
        XCTAssertEqual(viewController!.editButtonItem, viewController!.navigationItem.leftBarButtonItem)
    }
    
    func testSettingsViewControllerAllowsDeletionOfLocationRows() {
        let indexPath = IndexPath(row: 1, section: 1)
        let canDeleteRow = viewController!.tableView(viewController!.tableView, canEditRowAt: indexPath)
        XCTAssertTrue(canDeleteRow)
    }
    
    func testSettingsViewControllerDoesNotAllowDeletionOfFirstSection() {
        let indexPath = IndexPath(row: 0, section: 0)
        let canDeleteRow = viewController!.tableView(viewController!.tableView, canEditRowAt: indexPath)
        XCTAssertFalse(canDeleteRow)
    }
    
    func testSettingsViewControllerDoesNotAllowDeletionOfAddLocationRow() {
        let indexPath = IndexPath(row: 0, section: 1)
        let canDeleteRow = viewController!.tableView(viewController!.tableView, canEditRowAt: indexPath)
        XCTAssertFalse(canDeleteRow)
    }
    
    func testSettingsViewControllerDisplaysEditStyleForDeletingCitiesWhileEditing() {
        let indexPath = IndexPath(row: 1, section: 1)
        let editingStyle = viewController!.tableView(viewController!.tableView, editingStyleForRowAt: indexPath)
        XCTAssertEqual(UITableViewCellEditingStyle.delete, editingStyle)
    }
    
    func testSettingsViewControllerDisplaysNoEditStyleForAddingCitiesWhileEditing() {
        let indexPath = IndexPath(row: 0, section: 1)
        let editingStyle = viewController!.tableView(viewController!.tableView, editingStyleForRowAt: indexPath)
        XCTAssertEqual(UITableViewCellEditingStyle.none, editingStyle)
    }
    
    func testSettingsViewControllerDisplaysNoEditStyleForFirstSection() {
        let indexPath = IndexPath(row: 0, section: 0)
        let editingStyle = viewController!.tableView(viewController!.tableView, editingStyleForRowAt: indexPath)
        XCTAssertEqual(UITableViewCellEditingStyle.none, editingStyle)
    }
    
    func testSettingsViewControllerDeletesCitiesFromUserDefaultsWhenUserDeletesRow() {
        insertStubCitiesInUserDefaults()
        loadViewControllerView()
        let indexPath = IndexPath(row: 1, section: 1)
        viewController!.tableView.reloadData()
        viewController!.tableView(viewController!.tableView, commit: .delete, forRowAt: indexPath)
        XCTAssertEqual(1, viewController!.userDefaults!.favouriteLocations.count)
    }
    
    func testSettingsViewControllerDeletesLocationRowWhenUserDeletesLocation() {
        insertStubCitiesInUserDefaults()
        loadViewControllerView()
        let fakeTableView = FakeTableView()
        viewController?.tableView = fakeTableView
        let indexPath = IndexPath(row: 1, section: 1)
        viewController!.tableView(viewController!.tableView, commit: .delete, forRowAt: indexPath)
        XCTAssertEqual([indexPath], fakeTableView.deletedIndexPaths)
    }
    
    // MARK: Cities Addition
    
    func testSettingsViewControllerDoesNotPresentLocationSearchViewControllerWhenUserTapsOnFirstSectionRows() {
        let observer = MockNotificationObserver(notificationName: TestExtensionNotifications.DidAttemptSegue, sender: viewController)
        loadViewControllerView()
        let indexPath = IndexPath(row: 0, section: 0)
        viewController?.tableView(viewController!.tableView, didSelectRowAt: indexPath)
        XCTAssertFalse(observer.didReceiveNotification)
    }
    
    func testSettingsViewControllerPresentsLocationSearchViewControllerWhenUserTapsOnAddLocationRow() {
        loadViewControllerView()
        expectation(forNotification: TestExtensionNotifications.DidAttemptSegue, object: viewController) { (notification) -> Bool in
            let identifier = notification.userInfo?[TestExtensionNotificationsKeys.SegueIdentifier] as? String
            return identifier == SettingsViewController.Segues.AddLocationSegue.rawValue
        }
        let indexPath = IndexPath(row: 0, section: 1)
        viewController?.tableView(viewController!.tableView, didSelectRowAt: indexPath)
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testSettingsViewControllerDoesNotPresentLocationSearchViewControllerWhenUserTapsOnLocationRow() {
        loadViewControllerView()
        let observer = MockNotificationObserver(notificationName: TestExtensionNotifications.DidAttemptSegue, sender: viewController)
        let indexPath = IndexPath(row: 1, section: 1)
        viewController?.tableView(viewController!.tableView, didSelectRowAt: indexPath)
        XCTAssertFalse(observer.didReceiveNotification)
    }
    
    func testSettingsViewControllerSetsItselfAsLocationSearchViewControllerDelegateWhenPresentingIt() {
        let citySearchViewController = CitySearchViewController()
        let segue = UIStoryboardSegue(identifier: SettingsViewController.Segues.AddLocationSegue.rawValue, source: viewController!, destination: citySearchViewController)
        viewController?.prepare(for: segue, sender: IndexPath(row: 0, section: 1))
        XCTAssertTrue(viewController === citySearchViewController.delegate)
    }
    
    func testSettingsViewControllerDismissesLocationSearchWhenReceivingDelegateCallWithoutNewLocation() {
        let navigationController = FakeNavigationController(rootViewController: viewController!)
        let citySearchViewController = CitySearchViewController()
        viewController?.citySearchViewController(citySearchViewController, didFinishWithLocation: nil)
        XCTAssertTrue(navigationController.didAttemptPoppingViewController)
    }
    
    func testSettingsViewControllerDismissesLocationSearchWhenReceivingDelegateCallWithNewLocation() {
        let navigationController = FakeNavigationController(rootViewController: viewController!)
        let citySearchViewController = CitySearchViewController()
        let testLocation = Location(coordinate: CLLocationCoordinate2D(), name: "", country: "")
        viewController?.citySearchViewController(citySearchViewController, didFinishWithLocation: testLocation)
        XCTAssertTrue(navigationController.didAttemptPoppingViewController)
    }
    
    func testSettingsViewControllerAddsNewLocationToUserDefaultsWhenReceivingLocationSearchDelegateCallWithNewLocation() {
        let citySearchViewController = CitySearchViewController()
        let newLocation = Location(coordinate: CLLocationCoordinate2D(), name: "", country: "")
        var expectedCities = viewController!.userDefaults!.favouriteLocations
        expectedCities.append(newLocation)
        viewController?.citySearchViewController(citySearchViewController, didFinishWithLocation: newLocation)
        XCTAssertEqual(expectedCities, viewController!.userDefaults!.favouriteLocations)
    }
    
    func testSettingsViewControllerInsertsNewLocationRowToUserDefaultsWhenReceivingLocationSearchDelegateCallWithNewLocation() {
        let fakeTableView = FakeTableView()
        viewController?.tableView = fakeTableView
        let citySearchViewController = CitySearchViewController()
        let newLocation = Location(coordinate: CLLocationCoordinate2D(), name: "", country: "")
        viewController?.citySearchViewController(citySearchViewController, didFinishWithLocation: newLocation)
        XCTAssertEqual([IndexPath(row: 1, section: 1)], fakeTableView.insertedIndexPaths)
    }
    
    // MARK: - Editing State
    
    func testSettingsViewControllerHidesDoneButtonWhileEditing() {
        viewController?.isEditing = true
        XCTAssertNil(viewController!.navigationItem.rightBarButtonItem)
    }
    
    func testSettingsViewControllerResetsDoneButtonWhenFinishedEditing() {
        viewController?.isEditing = true
        viewController?.isEditing = false
        XCTAssertEqual(UIBarButtonItemStyle.done, viewController?.navigationItem.rightBarButtonItem?.style)
    }
    
    // MARK: - Sorting Cities
    
    func testSettingsViewControllerDoesNotAllowSortingAddCityRow() {
        loadViewControllerView()
        XCTAssertFalse(viewController!.tableView(viewController!.tableView, canMoveRowAt: IndexPath(row: 0, section: 1)))
    }
    
    func testSettingsViewControllerDoesNotAllowMovingLocationRowsToBeInPlaceOfAddCityRow() {
        loadViewControllerView()
        let fromIndexPath = IndexPath(item: 1, section: 1)
        let indexPathOfAddLocation = IndexPath(item: 0, section: 1)
        let targetIndexPath = viewController!.tableView(viewController!.tableView, targetIndexPathForMoveFromRowAt: fromIndexPath, toProposedIndexPath: indexPathOfAddLocation)
        let expectedTargetIndexPath = fromIndexPath
        XCTAssertEqual(expectedTargetIndexPath, targetIndexPath)
    }
    
    func testSettingsViewControllerAllowsMovingLocationRowsToBeSomewhereInPlaceOfAddCityRow() {
        loadViewControllerView()
        let fromIndexPath = IndexPath(item: 1, section: 1)
        let proposedIndexPath = IndexPath(item: 2, section: 1)
        let targetIndexPath = viewController!.tableView(viewController!.tableView, targetIndexPathForMoveFromRowAt: fromIndexPath, toProposedIndexPath: proposedIndexPath)
        let expectedTargetIndexPath = proposedIndexPath
        XCTAssertEqual(expectedTargetIndexPath, targetIndexPath)
    }
    
    func testSettingsViewControllerDoesNotAllowMovingLocationRowsToBeInPlaceOfAddCityRow2() {
        loadViewControllerView()
        let fromIndexPath = IndexPath(item: 2, section: 1)
        let indexPathOfAddLocation = IndexPath(item: 0, section: 1)
        let targetIndexPath = viewController!.tableView(viewController!.tableView, targetIndexPathForMoveFromRowAt: fromIndexPath, toProposedIndexPath: indexPathOfAddLocation)
        let expectedTargetIndexPath = fromIndexPath
        XCTAssertEqual(expectedTargetIndexPath, targetIndexPath)
    }
    
    func testSettingsViewControllerAllowsSortingCities() {
        loadViewControllerView()
        XCTAssertTrue(viewController!.tableView(viewController!.tableView, canMoveRowAt: IndexPath(row: 1, section: 1)))
    }
    
    func testSettingsViewControllerCanActuallySortCities() {
        let location1 = Location(coordinate: CLLocationCoordinate2D(), name: "Cupertino")
        let location2 = Location(coordinate: CLLocationCoordinate2D(), name: "San Diego")
        let location3 = Location(coordinate: CLLocationCoordinate2D(), name: "Mountain View")
        
        let initialLocations = [location1, location2, location3]
        let expectedLocations = [location3, location2, location1].map { (location) -> String in
            return location.name!
        }
        
        viewController?.userDefaults?.favouriteLocations = initialLocations
        loadViewControllerView()
        
        moveLocationFromIndex(3, toIndex: 1)
        moveLocationFromIndex(2, toIndex: 3)
        let actualLocations = viewController!.userDefaults!.favouriteLocations.map { (location) -> String in
            return location.name!
        }
        XCTAssertEqual(expectedLocations, actualLocations)
    }
    
    func testSettingsViewControllerDoesNotMoveAddCityRow() {
        let location1 = Location(coordinate: CLLocationCoordinate2D(), name: "Cupertino")
        let location2 = Location(coordinate: CLLocationCoordinate2D(), name: "San Diego")
        let location3 = Location(coordinate: CLLocationCoordinate2D(), name: "Mountain View")
        
        let initialLocations = [location1, location2, location3]
        let expectedLocations = initialLocations.map { (location) -> String in
            return location.name!
        }
        
        viewController?.userDefaults?.favouriteLocations = initialLocations
        loadViewControllerView()
        
        moveLocationFromIndex(3, toIndex: 0)
        moveLocationFromIndex(0, toIndex: 3)
        let actualLocations = viewController!.userDefaults!.favouriteLocations.map { (location) -> String in
            return location.name!
        }
        XCTAssertEqual(expectedLocations, actualLocations)
    }
    
    func testSettingsViewControllerDoesNotMoveLocationToSameIndexWhereItIsAlreadyLocated() {
        let location1 = Location(coordinate: CLLocationCoordinate2D(), name: "Cupertino")
        let location2 = Location(coordinate: CLLocationCoordinate2D(), name: "San Diego")
        let location3 = Location(coordinate: CLLocationCoordinate2D(), name: "Mountain View")
        
        let initialLocations = [location1, location2, location3]
        let expectedLocations = initialLocations.map { (location) -> String in
            return location.name!
        }
        
        viewController?.userDefaults?.favouriteLocations = initialLocations
        loadViewControllerView()
        
        moveLocationFromIndex(3, toIndex: 3)
        let actualLocations = viewController!.userDefaults!.favouriteLocations.map { (location) -> String in
            return location.name!
        }
        XCTAssertEqual(expectedLocations, actualLocations)
    }
    
    func testSettingsViewControllerDoesNotMoveLocationToAnIndexOutOfBounds() {
        let location1 = Location(coordinate: CLLocationCoordinate2D(), name: "Cupertino")
        let location2 = Location(coordinate: CLLocationCoordinate2D(), name: "San Diego")
        let location3 = Location(coordinate: CLLocationCoordinate2D(), name: "Mountain View")
        
        let initialLocations = [location1, location2, location3]
        let expectedLocations = initialLocations.map { (location) -> String in
            return location.name!
        }
        
        viewController?.userDefaults?.favouriteLocations = initialLocations
        loadViewControllerView()
        
        moveLocationFromIndex(3, toIndex: 4)
        moveLocationFromIndex(4, toIndex: 3)
        let actualLocations = viewController!.userDefaults!.favouriteLocations.map { (location) -> String in
            return location.name!
        }
        XCTAssertEqual(expectedLocations, actualLocations)
    }
    
    // MARK: - Helpers
    
    fileprivate func loadViewControllerView() {
        viewController!.beginAppearanceTransition(true, animated: false)
        viewController!.endAppearanceTransition()
    }
    
    fileprivate func insertStubCitiesInUserDefaults() {
        let londonCoordinate = CLLocationCoordinate2D(latitude: 51.5283063, longitude: -0.3824664)
        let london = Location(coordinate: londonCoordinate, name: "London", country: "UK")
        let sfCoordinate = CLLocationCoordinate2D(latitude: 37.7576792, longitude: -122.5078119)
        let sf = Location(coordinate: sfCoordinate, name: "San Francisco", country: "USA", state: "CA")
        viewController?.userDefaults?.favouriteLocations = [london, sf]
    }
    
    fileprivate func moveLocationFromIndex(_ fromIndex: Int, toIndex: Int) {
        let toIndexPath = IndexPath(row: toIndex, section: 1)
        let fromIndexPath = IndexPath(row: fromIndex, section: 1)
        viewController?.tableView(viewController!.tableView, moveRowAt: fromIndexPath, to: toIndexPath)
    }
    
    fileprivate func allowLocationServices() {
        let locationManager = viewController?.locationManager as? FakeUserLocationManager
        locationManager?.allowUseOfLocationServices = true
    }
    
    fileprivate func disallowLocationServices() {
        let locationManager = viewController?.locationManager as? FakeUserLocationManager
        locationManager?.allowUseOfLocationServices = false
    }

}

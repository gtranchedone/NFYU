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
    
    private(set) var didFinish = false
    
    func settingsViewControllerDidFinish(viewController: SettingsViewController) {
        didFinish = true
    }
    
}

class TestSettingsViewController: XCTestCase {

    var viewController: SettingsViewController?
    
    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        viewController = storyboard.instantiateViewControllerWithIdentifier("SettingsViewController") as? SettingsViewController
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
        XCTAssertEqual(UIBarButtonItemStyle.Done, viewController?.navigationItem.rightBarButtonItem?.style)
    }
    
    func testViewControllerTellsDelegateThatItHasFinishedWhenUserTapsDoneButtonInNavigationBar() {
        loadViewControllerView()
        let fakeDelegate = FakeSettingsViewControllerDelegate()
        viewController?.delegate = fakeDelegate
        let button = viewController?.navigationItem.rightBarButtonItem
        button?.target?.performSelector(button!.action)
        XCTAssertTrue(fakeDelegate.didFinish)
    }
    
    // MARK: - UITableViewDelegate
    // MARK: Cities Display Logic
    
    func testSettingsViewControllerAlwaysHasOneSectionInTableViewToBeAbleToAddCities() {
        loadViewControllerView()
        let numberOfSections = viewController!.numberOfSectionsInTableView(viewController!.tableView)
        XCTAssertEqual(1, numberOfSections)
    }
    
    func testSettingsViewControllerHasOneRowToAddCitiesIfUserHasNoFavouriteCities() {
        loadViewControllerView()
        let numberOfRows = viewController!.tableView(viewController!.tableView!, numberOfRowsInSection: 0)
        XCTAssertEqual(1, numberOfRows)
    }
    
    func testSettingsViewControllerHasOneRowToAddCitiesIfUserHasNoFavouriteCities2() {
        viewController?.userDefaults = nil
        loadViewControllerView()
        let numberOfRows = viewController!.tableView(viewController!.tableView!, numberOfRowsInSection: 0)
        XCTAssertEqual(1, numberOfRows)
    }
    
    func testSettingsViewControllerHasOneRowForEachFavouriteLocationPlusOneForAddingNewCities() {
        loadViewControllerView()
        insertStubCitiesInUserDefaults()
        let numberOfRows = viewController!.tableView(viewController!.tableView!, numberOfRowsInSection: 0)
        XCTAssertEqual(3, numberOfRows)
    }
    
    func testSettingsViewControllerDisplaysTheRightRowForAddingCitiesWhenNoOtherLocationIsPresent() {
        loadViewControllerView()
        let tableView = viewController!.tableView
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        let cell = viewController!.tableView(tableView, cellForRowAtIndexPath: indexPath)
        XCTAssertEqual(UITableViewCellAccessoryType.DisclosureIndicator, cell.accessoryType)
        XCTAssertEqual(NSLocalizedString("ADD_CITY_CELL_TITLE", comment: ""), cell.textLabel?.text)
    }
    
    func testSettingsViewControllerDisplaysTheRightRowForAddingCitiesWhenOtherCitiesArePresent() {
        loadViewControllerView()
        insertStubCitiesInUserDefaults()
        let tableView = viewController!.tableView
        let indexPath0 = NSIndexPath(forRow: 0, inSection: 0)
        let cell0 = viewController!.tableView(tableView, cellForRowAtIndexPath: indexPath0)
        XCTAssertEqual(UITableViewCellAccessoryType.DisclosureIndicator, cell0.accessoryType)
        XCTAssertEqual(NSLocalizedString("ADD_CITY_CELL_TITLE", comment: ""), cell0.textLabel?.text)
        XCTAssertEqual(UITableViewCellSelectionStyle.Default, cell0.selectionStyle)
        
        let indexPath1 = NSIndexPath(forRow: 1, inSection: 0)
        let cell1 = viewController!.tableView(tableView, cellForRowAtIndexPath: indexPath1)
        XCTAssertEqual(UITableViewCellSelectionStyle.None, cell1.selectionStyle)
        XCTAssertEqual(UITableViewCellAccessoryType.None, cell1.accessoryType)
        XCTAssertEqual("London, UK", cell1.textLabel?.text)
        
        let indexPath2 = NSIndexPath(forRow: 2, inSection: 0)
        let cell2 = viewController!.tableView(tableView, cellForRowAtIndexPath: indexPath2)
        XCTAssertEqual(UITableViewCellSelectionStyle.None, cell2.selectionStyle)
        XCTAssertEqual(UITableViewCellAccessoryType.None, cell2.accessoryType)
        XCTAssertEqual("San Francisco, USA", cell2.textLabel?.text)
    }
    
    // MARK: - UITableViewDelegate
    // MARK: Cities Deletion
    
    func testSettingsViewControllerHasEditButtonInNavigationBarWhenPresent() {
        loadViewControllerView()
        XCTAssertEqual(viewController!.editButtonItem(), viewController!.navigationItem.leftBarButtonItem)
    }
    
    func testSettingsViewControllerAllowsDeletionOfLocationRows() {
        let indexPath = NSIndexPath(forRow: 1, inSection: 0)
        let canDeleteRow = viewController!.tableView(viewController!.tableView, canEditRowAtIndexPath: indexPath)
        XCTAssertTrue(canDeleteRow)
    }
    
    func testSettingsViewControllerDoesNotAllowDeletionOfAddLocationRow() {
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        let canDeleteRow = viewController!.tableView(viewController!.tableView, canEditRowAtIndexPath: indexPath)
        XCTAssertFalse(canDeleteRow)
    }
    
    func testSettingsViewControllerDisplaysEditStyleForDeletingCitiesWhileEditing() {
        let indexPath = NSIndexPath(forRow: 1, inSection: 0)
        let editingStyle = viewController!.tableView(viewController!.tableView, editingStyleForRowAtIndexPath: indexPath)
        XCTAssertEqual(UITableViewCellEditingStyle.Delete, editingStyle)
    }
    
    func testSettingsViewControllerDisplaysNoEditStyleForAddingCitiesWhileEditing() {
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        let editingStyle = viewController!.tableView(viewController!.tableView, editingStyleForRowAtIndexPath: indexPath)
        XCTAssertEqual(UITableViewCellEditingStyle.None, editingStyle)
    }
    
    func testSettingsViewControllerDeletesCitiesFromUserDefaultsWhenUserDeletesRow() {
        insertStubCitiesInUserDefaults()
        loadViewControllerView()
        let indexPath = NSIndexPath(forRow: 1, inSection: 0)
        viewController!.tableView.reloadData()
        viewController!.tableView(viewController!.tableView, commitEditingStyle: .Delete, forRowAtIndexPath: indexPath)
        XCTAssertEqual(1, viewController!.userDefaults!.favouriteLocations.count)
    }
    
    func testSettingsViewControllerDeletesLocationRowWhenUserDeletesLocation() {
        insertStubCitiesInUserDefaults()
        loadViewControllerView()
        let fakeTableView = FakeTableView()
        viewController?.tableView = fakeTableView
        let indexPath = NSIndexPath(forRow: 1, inSection: 0)
        viewController!.tableView(viewController!.tableView, commitEditingStyle: .Delete, forRowAtIndexPath: indexPath)
        XCTAssertEqual([indexPath], fakeTableView.deletedIndexPaths)
    }
    
    // MARK: Cities Addition
    
    func testSettingsViewControllerPresentsLocationSearchViewControllerWhenUserTapsOnAddLocationRow() {
        loadViewControllerView()
        expectationForNotification(BaseViewController.TestExtensionNotifications.DidAttemptSegue, object: viewController) { (notification) -> Bool in
            let identifier = notification.userInfo?[BaseViewController.TestExtensionNotificationsKeys.SegueIdentifier] as? String
            return identifier == SettingsViewController.Segues.AddLocationSegue.rawValue
        }
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        viewController?.tableView(viewController!.tableView, didSelectRowAtIndexPath: indexPath)
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
    
    func testSettingsViewControllerDoesNotPresentLocationSearchViewControllerWhenUserTapsOnLocationRow() {
        loadViewControllerView()
        let observer = MockNotificationObserver(notificationName: BaseViewController.TestExtensionNotifications.DidAttemptSegue, sender: viewController)
        let indexPath = NSIndexPath(forRow: 1, inSection: 0)
        viewController?.tableView(viewController!.tableView, didSelectRowAtIndexPath: indexPath)
        XCTAssertFalse(observer.didReceiveNotification)
    }
    
    func testSettingsViewControllerSetsItselfAsLocationSearchViewControllerDelegateWhenPresentingIt() {
        let citySearchViewController = CitySearchViewController()
        let segue = UIStoryboardSegue(identifier: SettingsViewController.Segues.AddLocationSegue.rawValue, source: viewController!, destination: citySearchViewController)
        viewController?.prepareForSegue(segue, sender: NSIndexPath(forRow: 0, inSection: 0))
        XCTAssertTrue(viewController === citySearchViewController.delegate)
    }
    
    func testSettingsViewControllerDismissesLocationSearchWhenReceivingDelegateCallWithoutNewLocation() {
        let observer = MockNotificationObserver(notificationName: BaseViewController.TestExtensionNotifications.DidAttemptDismissingViewController, sender: viewController)
        let citySearchViewController = CitySearchViewController()
        viewController?.citySearchViewController(citySearchViewController, didFinishWithLocation: nil)
        XCTAssertTrue(observer.didReceiveNotification)
    }
    
    func testSettingsViewControllerDismissesLocationSearchWhenReceivingDelegateCallWithNewLocation() {
        let observer = MockNotificationObserver(notificationName: BaseViewController.TestExtensionNotifications.DidAttemptDismissingViewController, sender: viewController)
        let citySearchViewController = CitySearchViewController()
        viewController?.citySearchViewController(citySearchViewController, didFinishWithLocation: Location(coordinate: CLLocationCoordinate2D(), name: "", country: ""))
        XCTAssertTrue(observer.didReceiveNotification)
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
        XCTAssertEqual([NSIndexPath(forRow: 1, inSection: 0)], fakeTableView.insertedIndexPaths)
    }
    
    // MARK: - Helpers
    
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

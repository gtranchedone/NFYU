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
    
    func testSettingsViewControllerHasOneRowForEachFavouriteCityPlusOneForAddingNewCities() {
        loadViewControllerView()
        insertStubCitiesInUserDefaults()
        let numberOfRows = viewController!.tableView(viewController!.tableView!, numberOfRowsInSection: 0)
        XCTAssertEqual(3, numberOfRows)
    }
    
    func testSettingsViewControllerDisplaysTheRightRowForAddingCitiesWhenNoOtherCityIsPresent() {
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
    // MARK: Cities Editing
    
    func testSettingsViewControllerHasEditButtonInNavigationBarWhenPresent() {
        loadViewControllerView()
        XCTAssertEqual(viewController!.editButtonItem(), viewController!.navigationItem.rightBarButtonItem)
    }
    
    func testSettingsViewControllerAllowsDeletionOfCityRows() {
        let indexPath = NSIndexPath(forRow: 1, inSection: 0)
        let canDeleteRow = viewController!.tableView(viewController!.tableView, canEditRowAtIndexPath: indexPath)
        XCTAssertTrue(canDeleteRow)
    }
    
    func testSettingsViewControllerDoesNotAllowDeletionOfAddCityRow() {
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
        XCTAssertEqual(1, viewController!.userDefaults!.favouriteCities.count)
    }
    
    func testSettingsViewControllerDeletesCityRowWhenUserDeletesCity() {
        insertStubCitiesInUserDefaults()
        loadViewControllerView()
        let fakeTableView = FakeTableView()
        viewController?.tableView = fakeTableView
        let indexPath = NSIndexPath(forRow: 1, inSection: 0)
        viewController!.tableView(viewController!.tableView, commitEditingStyle: .Delete, forRowAtIndexPath: indexPath)
        XCTAssertEqual([indexPath], fakeTableView.deletedIndexPaths!)
    }
    
    // MARK: Helpers
    
    private func loadViewControllerView() {
        viewController!.beginAppearanceTransition(true, animated: false)
        viewController!.endAppearanceTransition()
    }
    
    private func insertStubCitiesInUserDefaults() {
        let london = City(coordinate: CLLocationCoordinate2D(latitude: 51.5283063, longitude: -0.3824664), name: "London", country: "UK")
        let sf = City(coordinate: CLLocationCoordinate2D(latitude: 37.7576792, longitude: -122.5078119), name: "San Francisco", country: "USA")
        viewController?.userDefaults?.favouriteCities = [london, sf]
    }

}

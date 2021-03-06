//
//  TestCitySearchViewController.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 04/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import XCTest
import MapKit
import CoreLocation
import AddressBook
@testable import NFYU

class MockCitySearchViewControllerDelegate: CitySearchViewControllerDelegate {
    
    fileprivate(set) var didFinish = false
    fileprivate(set) var returnedCity: Location?
    
    func citySearchViewController(_ viewController: CitySearchViewController, didFinishWithLocation location: Location?) {
        didFinish = true
        returnedCity = location
    }
    
}

// NOTE: FakeSearchBar is needed just to verify that becomeFirstResponder is called
// because -becomeFirstResponder returns false if the viewController isn't actually being presented
class FakeSearchBar: UISearchBar {
    
    fileprivate(set) var didBecomeFirstResponder = false
    
    override func becomeFirstResponder() -> Bool {
        didBecomeFirstResponder = true
        return false
    }
    
}

class TestCitySearchViewController: XCTestCase {

    var viewController: CitySearchViewController?
    
    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        viewController = storyboard.instantiateViewController(withIdentifier: "CitySearchViewController") as? CitySearchViewController
        viewController?.delegate = MockCitySearchViewControllerDelegate()
        viewController?.geocoder = FakeGeocoder()
        viewController?.loadViewIfNeeded()
    }
    
    override func tearDown() {
        viewController = nil
        super.tearDown()
    }

    // MARK: Initial Setup
    
    func testViewControllerGetsCorrectlyInitializedViaStoryboard() {
        XCTAssertNotNil(viewController)
    }
    
    func testViewControllerTitleIsCorrectlySet() {
        XCTAssertEqual(NSLocalizedString("CITY_SEARCH_VIEW_TITLE", comment: ""), viewController?.title)
    }
    
    func testViewControllerIsSearchBarDelegate() {
        XCTAssertTrue(viewController?.searchBar.delegate === viewController)
    }
    
    func testViewControllerMakesSearchBarFirstResponderWhenTheViewHasAppeared() {
        let searchBar = FakeSearchBar()
        viewController!.searchBar = searchBar
        viewController?.viewWillAppear(false) // needs to be on this exact method for the view to animate as expected
        XCTAssertTrue(searchBar.didBecomeFirstResponder)
    }
    
    func testViewControllerHasGeocoderByDefault() {
        let otherViewController = CitySearchViewController()
        XCTAssertNotNil(otherViewController.geocoder)
    }
    
    func testViewControllerIsTableViewDataSourceAndDelegate() {
        XCTAssertTrue(viewController!.tableView.delegate === viewController)
        XCTAssertTrue(viewController!.tableView.delegate === viewController)
    }
    
    // MARK: Search Logic
    
    func testViewControllerGeocodesSearchInputsLongerThenOneCharacter() { // Asian countries have city names of 2+ characters, e.g. Tokyo
        viewController?.searchBar(viewController!.searchBar, textDidChange: "To")
        let geocoder = viewController?.geocoder as! FakeGeocoder
        XCTAssertEqual("To", geocoder.lastGeocodedString)
    }
    
    func testViewControllerDoesNotGeocodeSearchInputsOfOneCharacterOnly() {
        viewController?.searchBar(viewController!.searchBar, textDidChange: "T")
        let geocoder = viewController?.geocoder as! FakeGeocoder
        XCTAssertNil(geocoder.lastGeocodedString)
    }
    
    func testViewControllerCancelsGeocoderIfAlreadyStarted() {
        let geocoder = viewController?.geocoder as! FakeGeocoder
        geocoder.canCallCompletionHandler = false
        viewController?.searchBar(viewController!.searchBar, textDidChange: "To")
        viewController?.searchBar(viewController!.searchBar, textDidChange: "Tok")
        XCTAssertTrue(geocoder.didCancelGeocode)
        XCTAssertEqual("Tok", geocoder.lastGeocodedString)
    }
    
    func testViewControllerReloadsTableViewDataWhenGeocoderFinishes() {
        let tableView = FakeTableView()
        viewController?.searchBar(viewController!.searchBar, textDidChange: "Tok")
        viewController!.tableView = tableView
        XCTAssertFalse(tableView.didReloadData)
    }
    
    func testViewControllerHasAlwaysOnlyOneTableViewSectionForDisplayingSearchResults() {
        XCTAssertEqual(1, viewController!.numberOfSections(in: viewController!.tableView))
    }
    
    func testViewControllerShowsZeroSearchResultsByDefault() {
        XCTAssertEqual(0, viewController!.tableView(viewController!.tableView, numberOfRowsInSection: 0))
    }
    
    func testViewControllerReturnsCorrectNumberOfResultsAfterGeocodingLocation() {
        let geocoder = viewController?.geocoder as! FakeGeocoder
        geocoder.stubPlacemarks = [placemarkForCupertino()]
        viewController?.searchBar(viewController!.searchBar, textDidChange: "Tok")
        XCTAssertEqual(1, viewController!.tableView(viewController!.tableView, numberOfRowsInSection: 0))
    }
    
    func testViewControllerShowsCorrectResultsAfterGeocodingLocation() {
        let geocoder = viewController?.geocoder as! FakeGeocoder
        geocoder.stubPlacemarks = [placemarkForCupertino()]
        viewController?.searchBar(viewController!.searchBar, textDidChange: "Tok")
        let cell = viewController!.tableView(viewController!.tableView, cellForRowAt: IndexPath(row: 0, section: 0))
        XCTAssertEqual("Cupertino, CA", cell.textLabel?.text)
    }
    
    func testViewControllerShowsCorrectResultsAfterGeocodingLocation2() {
        let geocoder = viewController?.geocoder as! FakeGeocoder
        geocoder.stubPlacemarks = [placemarkForLondon()]
        viewController?.searchBar(viewController!.searchBar, textDidChange: "Tok")
        let cell = viewController!.tableView(viewController!.tableView, cellForRowAt: IndexPath(row: 0, section: 0))
        XCTAssertEqual("London, UK", cell.textLabel?.text)
    }
    
    func testViewControllerInformsDelegateWhenUserSelectsCityFromSearchResults() {
        let geocoder = viewController?.geocoder as! FakeGeocoder
        geocoder.stubPlacemarks = [placemarkForLondon()]
        viewController?.searchBar(viewController!.searchBar, textDidChange: "Tok")
        viewController?.tableView(viewController!.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        let delegate = viewController?.delegate as! MockCitySearchViewControllerDelegate
        let expectedCity = Location(coordinate: CLLocationCoordinate2D(latitude: 10, longitude: 20), name: "London", country: "UK")
        let actualCity = delegate.returnedCity
        XCTAssertEqual(expectedCity, actualCity)
    }
    
    // MARK: Private
    
    // NOTE: AddressBook is deprecated but using Contacts keys as suggested in the deprecation warning makes returned CLPlacemark not work as expected
    
    fileprivate func placemarkForCupertino() -> CLPlacemark {
        let placemarkLocation = CLLocationCoordinate2D(latitude: 10, longitude: 20)
        let placemarkAddress: [String : AnyObject] = [kABPersonAddressCityKey as String: "Cupertino" as AnyObject,
                                                      kABPersonAddressStateKey as String: "CA" as AnyObject,
                                                      kABPersonAddressCountryKey as String: "USA" as AnyObject]
        let placemark = MKPlacemark(coordinate: placemarkLocation, addressDictionary: placemarkAddress)
        return placemark
    }
    
    fileprivate func placemarkForLondon() -> CLPlacemark {
        let placemarkLocation = CLLocationCoordinate2D(latitude: 10, longitude: 20)
        let placemarkAddress: [String : AnyObject] = [kABPersonAddressCityKey as String: "London" as AnyObject,
                                                      kABPersonAddressCountryKey as String: "UK" as AnyObject]
        let placemark = MKPlacemark(coordinate: placemarkLocation, addressDictionary: placemarkAddress)
        return placemark
    }

}

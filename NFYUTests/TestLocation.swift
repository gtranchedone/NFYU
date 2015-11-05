//
//  TestLocation.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 04/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import XCTest
import CoreLocation
@testable import NFYU

class TestLocation: XCTestCase {

    // MARK: Location Displayable Properties
    
    func testUSLocationWithRegionFormatsDisplayableNameAppropriately() {
        let city = Location(coordinate: CLLocationCoordinate2D(), name: "Smallville", country: "USA", state: "Kent")
        XCTAssertEqual("Smallville, Kent", city.displayableName)
    }
    
    func testUSLocationWithRegionFormatsDisplayableNameAppropriately2() {
        let city = Location(coordinate: CLLocationCoordinate2D(), name: "Smallville", country: "United States", state: "Kent")
        XCTAssertEqual("Smallville, Kent", city.displayableName)
    }
    
    func testUSLocationWithRegionFormatsDisplayableNameAppropriatelyWhenStateMissing() {
        let city = Location(coordinate: CLLocationCoordinate2D(), name: "Smallville", country: "United States")
        XCTAssertEqual("Smallville, United States", city.displayableName)
    }
    
    func testLocationWithoutRegionFormatsDisplayableNameAppropriately() {
        let city = Location(coordinate: CLLocationCoordinate2D(), name: "London", country: "UK")
        XCTAssertEqual("London, UK", city.displayableName)
    }
    
    func testLocationFormatTakesIntoAccountStateOnlyForUnitedStates() {
        let city = Location(coordinate: CLLocationCoordinate2D(), name: "London", country: "UK", state: "England", city: "London")
        XCTAssertEqual("London, UK", city.displayableName)
    }
    
    func testLocationFormatTakesIntoAccountPlaceNameIfDifferentThenLocationName() {
        let city = Location(coordinate: CLLocationCoordinate2D(), name: "Brixton", country: "UK", state: "England", city: "London")
        XCTAssertEqual("Brixton, London, UK", city.displayableName)
    }
    
    func testLocationFormatWhenAllFieldsButNameAreMissing() {
        let location = Location(coordinate: CLLocationCoordinate2D(), name: "Some Location")
        XCTAssertEqual("Some Location", location.displayableName)
    }
    
    // MARK: Equality
    
    func testTwoCitiesAreEqualWhenTheyHaveSameNameAndSameCountryAndSameRegion() {
        let city1 = Location(coordinate: CLLocationCoordinate2D(), name: "Smallville", country: "USA", state: "Kent")
        let city2 = Location(coordinate: CLLocationCoordinate2D(), name: "Smallville", country: "USA", state: "Kent")
        XCTAssertEqual(city1, city2)
    }
    
    func testTwoCitiesAreEqualWhenTheyHaveSameNameAndSameCountryAndNoRegion() {
        let city1 = Location(coordinate: CLLocationCoordinate2D(), name: "London", country: "UK")
        let city2 = Location(coordinate: CLLocationCoordinate2D(), name: "London", country: "UK")
        XCTAssertEqual(city1, city2)
    }
    
    func testTwoCitiesAreNotEqualWhenTheyHaveSameNameAndSameCountryAndDifferentRegion() {
        let city1 = Location(coordinate: CLLocationCoordinate2D(), name: "Smallville", country: "USA", state: "Kent")
        let city2 = Location(coordinate: CLLocationCoordinate2D(), name: "Smallville", country: "USA", state: "FantasyLand")
        XCTAssertNotEqual(city1, city2)
    }
    
    func testTwoCitiesAreNotEqualWhenTheyHaveSameNameAndDifferentCountryAndSameRegion() {
        let city1 = Location(coordinate: CLLocationCoordinate2D(), name: "London", country: "UK")
        let city2 = Location(coordinate: CLLocationCoordinate2D(), name: "London", country: "USA")
        XCTAssertNotEqual(city1, city2)
    }

    func testTwoCitiesAreNotEqualWhenTheyHaveDifferentNameAndSameCountryAndSameRegion() {
        let city1 = Location(coordinate: CLLocationCoordinate2D(), name: "Smallville", country: "USA", state: "Kent")
        let city2 = Location(coordinate: CLLocationCoordinate2D(), name: "Metropolis", country: "USA", state: "Kent")
        XCTAssertNotEqual(city1, city2)
    }
    
    func testTwoEqualLocationsHaveSameHashValue() {
        let city1 = Location(coordinate: CLLocationCoordinate2D(), name: "Smallville", country: "USA", state: "Kent")
        let city2 = Location(coordinate: CLLocationCoordinate2D(), name: "Smallville", country: "USA", state: "Kent")
        XCTAssertEqual(city1.hashValue, city2.hashValue)
    }
    
    func testTwoEqualLocationsAreEqualWhenUsingNSObjectEquality() {
        let city1 = Location(coordinate: CLLocationCoordinate2D(), name: "Smallville", country: "USA", state: "Kent")
        let city2 = Location(coordinate: CLLocationCoordinate2D(), name: "Smallville", country: "USA", state: "Kent")
        XCTAssertTrue(city1.isEqual(city2))
    }
    
    func testTwoUnequalLocationsAreNotEqualWhenUsingNSObjectEquality() {
        let city1 = Location(coordinate: CLLocationCoordinate2D(), name: "Smallville", country: "USA", state: "Kent")
        let city2 = Location(coordinate: CLLocationCoordinate2D(), name: "Metropolis", country: "USA", state: "Kent")
        XCTAssertFalse(city1.isEqual(city2))
    }
    
    func testLocationCanBeComparedWithNonLocationObjectUsingNSObjectEquality() {
        let city = Location(coordinate: CLLocationCoordinate2D(), name: "Smallville", country: "USA", state: "Kent")
        let array = [city]
        XCTAssertFalse(city.isEqual(array))
    }
    
    // MARK: NSCoding
    
    func testLocationCanBeEncoded() {
        let city = Location(coordinate: CLLocationCoordinate2D(latitude: 0.10, longitude: 40.2), name: "Brixton", country: "UK", state: "England", city: "London")
        let data = NSKeyedArchiver.archivedDataWithRootObject(city)
        XCTAssertNotNil(data)
    }
    
    func testLocationCanBeDecoded() {
        let city1 = Location(coordinate: CLLocationCoordinate2D(latitude: 0.10, longitude: 40.2), name: "Brixton", country: "UK", state: "England", city: "London")
        let data = NSKeyedArchiver.archivedDataWithRootObject(city1)
        let city2 = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! Location
        XCTAssertEqual(city1, city2)
    }
    
}

//
//  TestCity.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 04/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import XCTest
import CoreLocation
@testable import NFYU

class TestCity: XCTestCase {

    func testUSCityWithRegionFormatsDisplayableNameAppropriately() {
        let city = City(coordinate: CLLocationCoordinate2D(), name: "Smallville", country: "USA", state: "Kent")
        XCTAssertEqual("Smallville, Kent", city.displayableName)
    }
    
    func testUSCityWithRegionFormatsDisplayableNameAppropriately2() {
        let city = City(coordinate: CLLocationCoordinate2D(), name: "Smallville", country: "United States", state: "Kent")
        XCTAssertEqual("Smallville, Kent", city.displayableName)
    }
    
    func testCityWithoutRegionFormatsDisplayableNameAppropriately() {
        let city = City(coordinate: CLLocationCoordinate2D(), name: "London", country: "UK")
        XCTAssertEqual("London, UK", city.displayableName)
    }
    
    func testCityFormatTakesIntoAccountStateOnlyForUnitedStates() {
        let city = City(coordinate: CLLocationCoordinate2D(), name: "London", country: "UK", state: "England", city: "London")
        XCTAssertEqual("London, UK", city.displayableName)
    }
    
    func testCityFormatTakesIntoAccountPlaceNameIfDifferentThenCityName() {
        let city = City(coordinate: CLLocationCoordinate2D(), name: "Brixton", country: "UK", state: "England", city: "London")
        XCTAssertEqual("Brixton, London, UK", city.displayableName)
    }
    
    func testTwoCitiesAreEqualWhenTheyHaveSameNameAndSameCountryAndSameRegion() {
        let city1 = City(coordinate: CLLocationCoordinate2D(), name: "Smallville", country: "USA", state: "Kent")
        let city2 = City(coordinate: CLLocationCoordinate2D(), name: "Smallville", country: "USA", state: "Kent")
        XCTAssertEqual(city1, city2)
    }
    
    func testTwoCitiesAreEqualWhenTheyHaveSameNameAndSameCountryAndNoRegion() {
        let city1 = City(coordinate: CLLocationCoordinate2D(), name: "London", country: "UK")
        let city2 = City(coordinate: CLLocationCoordinate2D(), name: "London", country: "UK")
        XCTAssertEqual(city1, city2)
    }
    
    func testTwoCitiesAreNotEqualWhenTheyHaveSameNameAndSameCountryAndDifferentRegion() {
        let city1 = City(coordinate: CLLocationCoordinate2D(), name: "Smallville", country: "USA", state: "Kent")
        let city2 = City(coordinate: CLLocationCoordinate2D(), name: "Smallville", country: "USA", state: "FantasyLand")
        XCTAssertNotEqual(city1, city2)
    }
    
    func testTwoCitiesAreNotEqualWhenTheyHaveSameNameAndDifferentCountryAndSameRegion() {
        let city1 = City(coordinate: CLLocationCoordinate2D(), name: "London", country: "UK")
        let city2 = City(coordinate: CLLocationCoordinate2D(), name: "London", country: "USA")
        XCTAssertNotEqual(city1, city2)
    }

    func testTwoCitiesAreNotEqualWhenTheyHaveDifferentNameAndSameCountryAndSameRegion() {
        let city1 = City(coordinate: CLLocationCoordinate2D(), name: "Smallville", country: "USA", state: "Kent")
        let city2 = City(coordinate: CLLocationCoordinate2D(), name: "Metropolis", country: "USA", state: "Kent")
        XCTAssertNotEqual(city1, city2)
    }
    
}

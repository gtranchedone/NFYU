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

    func testCityWithRegionFormatsDisplayableNameAppropriately() {
        let city = City(coordinate: CLLocationCoordinate2D(), name: "Smallville", country: "USA", region: "Kent")
        XCTAssertEqual("Smallville, Kent", city.displayableName)
    }
    
    func testCityWithoutRegionFormatsDisplayableNameAppropriately() {
        let city = City(coordinate: CLLocationCoordinate2D(), name: "London", country: "UK")
        XCTAssertEqual("London, UK", city.displayableName)
    }
    
    func testTwoCitiesAreEqualWhenTheyHaveSameNameAndSameCountryAndSameRegion() {
        let city1 = City(coordinate: CLLocationCoordinate2D(), name: "Smallville", country: "USA", region: "Kent")
        let city2 = City(coordinate: CLLocationCoordinate2D(), name: "Smallville", country: "USA", region: "Kent")
        XCTAssertEqual(city1, city2)
    }
    
    func testTwoCitiesAreEqualWhenTheyHaveSameNameAndSameCountryAndNoRegion() {
        let city1 = City(coordinate: CLLocationCoordinate2D(), name: "London", country: "UK")
        let city2 = City(coordinate: CLLocationCoordinate2D(), name: "London", country: "UK")
        XCTAssertEqual(city1, city2)
    }
    
    func testTwoCitiesAreNotEqualWhenTheyHaveSameNameAndSameCountryAndDifferentRegion() {
        let city1 = City(coordinate: CLLocationCoordinate2D(), name: "Smallville", country: "USA", region: "Kent")
        let city2 = City(coordinate: CLLocationCoordinate2D(), name: "Smallville", country: "USA", region: "FantasyLand")
        XCTAssertNotEqual(city1, city2)
    }
    
    func testTwoCitiesAreNotEqualWhenTheyHaveSameNameAndDifferentCountryAndSameRegion() {
        let city1 = City(coordinate: CLLocationCoordinate2D(), name: "London", country: "UK")
        let city2 = City(coordinate: CLLocationCoordinate2D(), name: "London", country: "USA")
        XCTAssertNotEqual(city1, city2)
    }

    func testTwoCitiesAreNotEqualWhenTheyHaveDifferentNameAndSameCountryAndSameRegion() {
        let city1 = City(coordinate: CLLocationCoordinate2D(), name: "Smallville", country: "USA", region: "Kent")
        let city2 = City(coordinate: CLLocationCoordinate2D(), name: "Metropolis", country: "USA", region: "Kent")
        XCTAssertNotEqual(city1, city2)
    }
    
}

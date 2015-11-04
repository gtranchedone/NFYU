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

}

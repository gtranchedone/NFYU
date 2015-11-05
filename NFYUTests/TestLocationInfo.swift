//
//  TestLocationInfo.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 05/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import XCTest
@testable import NFYU

class TestLocationInfo: XCTestCase {

    func testTwoLocationInfoAreEqualIfTheyHaveSameID() {
        let location1 = LocationInfo(cityID: "cityID1", cityName: "cityName1", cityCountry: "cityCountry1")
        let location2 = LocationInfo(cityID: "cityID1", cityName: "cityName1", cityCountry: "cityCountry1")
        XCTAssertEqual(location1, location2)
    }
    
    func testTwoLocationInfoAreNotEqualIfTheyHaveDifferentID() {
        let location1 = LocationInfo(cityID: "cityID1", cityName: "cityName1", cityCountry: "cityCountry1")
        let location2 = LocationInfo(cityID: "cityID2", cityName: "cityName2", cityCountry: "cityCountry2")
        XCTAssertNotEqual(location1, location2)
    }

}

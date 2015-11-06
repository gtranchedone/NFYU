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
        let location1 = LocationInfo(id: "cityID1", name: "cityName1", country: "cityCountry1")
        let location2 = LocationInfo(id: "cityID1", name: "cityName1", country: "cityCountry1")
        XCTAssertEqual(location1, location2)
    }
    
    func testTwoLocationInfoAreNotEqualIfTheyHaveDifferentID() {
        let location1 = LocationInfo(id: "cityID1", name: "cityName1", country: "cityCountry1")
        let location2 = LocationInfo(id: "cityID2", name: "cityName2", country: "cityCountry2")
        XCTAssertNotEqual(location1, location2)
    }

}

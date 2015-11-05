//
//  TestForecast.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 05/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import XCTest
@testable import NFYU

class TestForecast: XCTestCase {

    func testTwoForecastsAreEqualIfTheyAreTheSameObject() {
        let forecast1 = Forecast()
        let forecast2 = forecast1
        XCTAssertEqual(forecast1, forecast2)
    }
    
    func testTwoForecastsAreNotEqualIfTheyAreNotTheSameObject() {
        let forecast1 = Forecast()
        let forecast2 = Forecast()
        XCTAssertNotEqual(forecast1, forecast2)
    }

}

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

    func testTwoForecastsAreEqualIfTheyHaveSameCityIDAndDate() {
        let date = NSDate()
        let forecast1 = Forecast(date: date, cityID: "cityID1", weather: .Clear, minTemperature: 0, maxTemperature: 0, currentTemperature: 0)
        let forecast2 = Forecast(date: date, cityID: "cityID1", weather: .Clear, minTemperature: 0, maxTemperature: 0, currentTemperature: 0)
        XCTAssertEqual(forecast1, forecast2)
    }
    
    func testTwoForecastsAreNotEqualIfTheyHaveSameCityIDAndDifferentDate() {
        let forecast1 = Forecast(date: NSDate.distantPast(), cityID: "cityID1", weather: .Clear, minTemperature: 0, maxTemperature: 0, currentTemperature: 0)
        let forecast2 = Forecast(date: NSDate.distantFuture(), cityID: "cityID1", weather: .Clear, minTemperature: 0, maxTemperature: 0, currentTemperature: 0)
        XCTAssertNotEqual(forecast1, forecast2)
    }
    
    func testTwoForecastsAreNotEqualIfTheyHaveDifferentCityIDAndSameDate() {
        let date = NSDate()
        let forecast1 = Forecast(date: date, cityID: "cityID1", weather: .Clear, minTemperature: 0, maxTemperature: 0, currentTemperature: 0)
        let forecast2 = Forecast(date: date, cityID: "cityID2", weather: .Clear, minTemperature: 0, maxTemperature: 0, currentTemperature: 0)
        XCTAssertNotEqual(forecast1, forecast2)
    }
    
    func testTwoForecastsAreNotEqualIfTheyHaveDifferentCityIDAndDate() {
        let forecast1 = Forecast(date: NSDate(), cityID: "cityID1", weather: .Clear, minTemperature: 0, maxTemperature: 0, currentTemperature: 0)
        let forecast2 = Forecast(date: NSDate(), cityID: "cityID2", weather: .Clear, minTemperature: 0, maxTemperature: 0, currentTemperature: 0)
        XCTAssertNotEqual(forecast1, forecast2)
    }

}

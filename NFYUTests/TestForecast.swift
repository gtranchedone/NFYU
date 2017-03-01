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
        let date = Date()
        let forecast1 = Forecast(date: date, cityID: "cityID1", weather: .Clear, minTemperature: 0, maxTemperature: 0, currentTemperature: 0)
        let forecast2 = Forecast(date: date, cityID: "cityID1", weather: .Clear, minTemperature: 0, maxTemperature: 0, currentTemperature: 0)
        XCTAssertEqual(forecast1, forecast2)
    }
    
    func testTwoForecastsAreNotEqualIfTheyHaveSameCityIDAndDifferentDate() {
        let forecast1 = Forecast(date: Date.distantPast, cityID: "cityID1", weather: .Clear, minTemperature: 0, maxTemperature: 0, currentTemperature: 0)
        let forecast2 = Forecast(date: Date.distantFuture, cityID: "cityID1", weather: .Clear, minTemperature: 0, maxTemperature: 0, currentTemperature: 0)
        XCTAssertNotEqual(forecast1, forecast2)
    }
    
    func testTwoForecastsAreNotEqualIfTheyHaveDifferentCityIDAndSameDate() {
        let date = Date()
        let forecast1 = Forecast(date: date, cityID: "cityID1", weather: .Clear, minTemperature: 0, maxTemperature: 0, currentTemperature: 0)
        let forecast2 = Forecast(date: date, cityID: "cityID2", weather: .Clear, minTemperature: 0, maxTemperature: 0, currentTemperature: 0)
        XCTAssertNotEqual(forecast1, forecast2)
    }
    
    func testTwoForecastsAreNotEqualIfTheyHaveDifferentCityIDAndDate() {
        let forecast1 = Forecast(date: Date(), cityID: "cityID1", weather: .Clear, minTemperature: 0, maxTemperature: 0, currentTemperature: 0)
        let forecast2 = Forecast(date: Date(), cityID: "cityID2", weather: .Clear, minTemperature: 0, maxTemperature: 0, currentTemperature: 0)
        XCTAssertNotEqual(forecast1, forecast2)
    }

}

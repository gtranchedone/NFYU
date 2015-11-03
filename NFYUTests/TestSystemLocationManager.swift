//
//  TestSystemLocationManager.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 03/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import XCTest

class TestSystemLocationManager: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    // TODO: test behaviour of viewController when canUseUserLocation == true but location services are disabled -> Test this in LocationManager implementation instead
    // TODO: test behaviour with different location services authorization statuses -> Also test this in LocationManager implementation, e.g. return error, or wait while user decides if grant auth

}

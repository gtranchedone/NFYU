//
//  TestAppDelegate.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 01/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import UIKit
import XCTest
@testable import NFYU

class TestAppDelegate: XCTestCase {

    var appDelegate: AppDelegate?
    
    override func setUp() {
        super.setUp()
        appDelegate = AppDelegate()
        setUpAppDelegate(appDelegate!)
    }
    
    override func tearDown() {
        appDelegate = nil
        super.tearDown()
    }
    
    func testAppDelegateHasSystemUserDefaultsWhenInitialized() {
        XCTAssert(appDelegate?.userDefaults === NSUserDefaults.standardUserDefaults())
    }

    func testAppDelegateInjectsUserDefaultsIntoMainViewController() {
        appDelegate?.userDefaults = FakeUserDefaults()
        appDelegate?.application(UIApplication.sharedApplication(), didFinishLaunchingWithOptions: nil)
        let viewController = appDelegate?.window?.rootViewController as? WeatherViewController
        XCTAssert(appDelegate?.userDefaults === viewController?.userDefaults,
            "The main view controller should only know system settings via the user defaults passed by the AppDelegate")
    }
    
    func testAppDelegateHasSystemLocationManagerWhenInitialized() {
        let locationManager = appDelegate!.locationManager as? SystemLocationManager
        XCTAssertNotNil(locationManager)
    }
    
    func testAppDelegateInjectsLocationManagerIntoMainViewController() {
        appDelegate?.application(UIApplication.sharedApplication(), didFinishLaunchingWithOptions: nil)
        let viewController = appDelegate?.window?.rootViewController as? WeatherViewController
        XCTAssert(appDelegate?.locationManager === viewController?.locationManager,
            "The main view controller should only know system settings via the user defaults passed by the AppDelegate")
    }
    
    // MARK: Private

    func setUpAppDelegate(appDelegate: AppDelegate) {
        appDelegate.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        appDelegate.window?.rootViewController = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateInitialViewController()
    }
    
}

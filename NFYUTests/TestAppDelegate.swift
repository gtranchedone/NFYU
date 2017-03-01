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
        XCTAssert(appDelegate?.userDefaults === Foundation.UserDefaults.standard)
    }

    func testAppDelegateInjectsUserDefaultsIntoMainViewController() {
        appDelegate?.userDefaults = FakeUserDefaults()
        let _ = appDelegate?.application(UIApplication.shared, didFinishLaunchingWithOptions: nil)
        let viewController = appDelegate?.window?.rootViewController as? WeatherViewController
        XCTAssert(appDelegate?.userDefaults === viewController?.userDefaults,
            "The main view controller should only know system settings via the user defaults passed by the AppDelegate")
    }
    
    func testAppDelegateHasSystemLocationManagerWhenInitialized() {
        let locationManager = appDelegate!.locationManager as? SystemUserLocationManager
        XCTAssertNotNil(locationManager)
    }
    
    func testAppDelegateInjectsLocationManagerIntoMainViewController() {
        let _ = appDelegate?.application(UIApplication.shared, didFinishLaunchingWithOptions: nil)
        let viewController = appDelegate?.window?.rootViewController as? WeatherViewController
        XCTAssert(appDelegate?.locationManager === viewController?.locationManager,
            "The main view controller should only know system settings via the user defaults passed by the AppDelegate")
    }
    
    func testAppDelegateHasOpenWeatherAPIClientWhenInitialized() {
        let requestSerializer = appDelegate!.apiClient.requestSerializer as? OpenWeatherAPIClientRequestSerializer
        XCTAssertNotNil(requestSerializer)
        let responseSerializer = appDelegate!.apiClient.responseSerializer as? OpenWeatherAPIClientResponseSerializer
        XCTAssertNotNil(responseSerializer)
    }
    
    func testAppDelegateInjectsAPIClientIntoMainViewController() {
        let _ = appDelegate?.application(UIApplication.shared, didFinishLaunchingWithOptions: nil)
        let viewController = appDelegate?.window?.rootViewController as? WeatherViewController
        XCTAssert(appDelegate?.apiClient === viewController!.apiClient)
    }
    
    func testAppDelegateHasAnAutoupdatingLocale() {
        XCTAssertEqual(appDelegate?.currentLocale, Locale.autoupdatingCurrent)
    }
    
    func testAppDelegateSetsPreferenceForUsingCelsiusDegreesDependingOnCurrentLocale() {
        appDelegate?.currentLocale = Locale(identifier: "en_US")
        let _ = appDelegate?.application(UIApplication.shared, didFinishLaunchingWithOptions: nil)
        XCTAssertTrue(appDelegate!.userDefaults.useFahrenheitDegrees)
    }
    
    func testAppDelegateSetsPreferenceForUsingFahrenheitDegreesDependingOnCurrentLocale() {
        appDelegate?.currentLocale = Locale(identifier: "en_GB")
        let _ = appDelegate?.application(UIApplication.shared, didFinishLaunchingWithOptions: nil)
        XCTAssertFalse(appDelegate!.userDefaults.useFahrenheitDegrees)
    }
    
    // MARK: Private

    func setUpAppDelegate(_ appDelegate: AppDelegate) {
        appDelegate.window = UIWindow(frame: UIScreen.main.bounds)
        appDelegate.window?.rootViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController()
    }
    
}

//
//  TestWeatherViewController.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 01/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import XCTest
@testable import NFYU

class TestWeatherViewController: XCTestCase {

    var viewController: WeatherViewController?
    
    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        viewController = storyboard.instantiateInitialViewController() as? WeatherViewController
        viewController?.userDefaults = FakeUserDefaults()
    }
    
    override func tearDown() {
        viewController = nil
        super.tearDown()
    }
    
    func testWeatherViewControllerCanBeCorrectlyInitialized() {
        XCTAssertNotNil(viewController)
    }
    
    func testWeatherViewControllerHasSetupViewHiddenByDefault() {
        viewController?.userDefaults = nil
        loadViewControllerView()
        XCTAssertFalse(viewController!.initialSetupView.hidden)
    }
    
    func testWeatherViewControllerHasActivityIndicatorHiddenByDefault() {
        loadViewControllerView()
        XCTAssertTrue(viewController!.activityIndicator.hidden)
    }
    
    func testWeatherViewControllerHasBackgroundMessageLabelHiddenByDefault() {
        loadViewControllerView()
        XCTAssertTrue(viewController!.backgroundMessageLabel.hidden)
    }
    
    func testWeatherViewControllerHasPageControlHiddenByDefault() {
        loadViewControllerView()
        XCTAssertTrue(viewController!.pageControl.hidden)
    }
    
    func testWeatherViewControllerShowsInitialSetUpViewIfUserDidNotYetSetUpLocations() {
        viewController!.userDefaults!.didSetUpLocations = false
        loadViewControllerView()
        XCTAssertFalse(viewController!.initialSetupView.hidden)
    }
    
    func testWeatherViewControllerHidesInitialSetUpViewIfUserDidAlreadySetUpLocations() {
        viewController!.userDefaults!.didSetUpLocations = true
        loadViewControllerView()
        XCTAssertTrue(viewController!.initialSetupView.hidden)
    }
    
    // MARK: Private
    
    func loadViewControllerView() {
        viewController!.beginAppearanceTransition(true, animated: false)
        viewController!.endAppearanceTransition()
    }
    
}

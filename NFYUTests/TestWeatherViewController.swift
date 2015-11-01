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
    
    func testWeatherViewControllerPresentsIntroViewControllerIfTheLatterWasNeverPresented() {
        viewController?.userDefaults?.setBool(false, forKey: UserDefaultsKeys.DidPresentIntro)
        let notificationName = BaseViewController.TestExtensionNotifications.DidAttemptSegue
        expectationForNotification(notificationName, object: viewController) { (notification) -> Bool in
            let userInfo = notification.userInfo as? [NSObject : String]
            let segueIdentifier = userInfo?[BaseViewController.TestExtensionNotificationsKeys.SegueIdentifier]
            let didPerformExpectedSegue = WeatherViewController.SegueIdentifier.Intro == segueIdentifier
            return didPerformExpectedSegue
        }
        viewController?.beginAppearanceTransition(true, animated: false)
        viewController?.endAppearanceTransition()
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }

    func testWeatherViewControllerDoesNotPresentIntroViewControllerIfLatterWasAlreadyPresented() {
        viewController?.userDefaults?.setBool(true, forKey: UserDefaultsKeys.DidPresentIntro)
        let notificationName = BaseViewController.TestExtensionNotifications.DidAttemptSegue
        let observer = MockNotificationObserver(notificationName: notificationName, sender: viewController, crashIfReceived: true)
        viewController?.beginAppearanceTransition(true, animated: false)
        viewController?.endAppearanceTransition()
        observer.verify()
    }
    
}

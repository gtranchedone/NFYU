//
//  AppDelegate.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 01/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var apiClient: APIClient = APIClient(requestSerializer: OpenWeatherAPIClientRequestSerializer(),
                                         responseSerializer: OpenWeatherAPIClientResponseSerializer())
    var userDefaults: UserDefaults = NSUserDefaults.standardUserDefaults()
    var locationManager: LocationFinder = SystemLocationFinder()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let viewController = window?.rootViewController as? WeatherViewController
        viewController?.locationManager = locationManager
        viewController?.userDefaults = userDefaults
        viewController?.apiClient = apiClient
        return true
    }

}


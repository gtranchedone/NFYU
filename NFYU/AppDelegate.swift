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
    
    var userDefaults: UserDefaults = Foundation.UserDefaults.standard
    var locationManager: UserLocationManager = SystemUserLocationManager()
    var currentLocale: Locale = Locale.autoupdatingCurrent

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        updateRootViewController()
        updateDefaultSettings()
        return true
    }
    
    private func updateDefaultSettings() {
        let measurementSystem = (currentLocale as NSLocale).object(forKey: NSLocale.Key.measurementSystem) as! String
        userDefaults.useFahrenheitDegrees = (measurementSystem == "U.S.") // this is what iOS gives us
    }
    
    private func updateRootViewController() {
        let viewController = window?.rootViewController as? WeatherViewController
        viewController?.locationManager = locationManager
        viewController?.userDefaults = userDefaults
        viewController?.apiClient = apiClient
    }
    
}

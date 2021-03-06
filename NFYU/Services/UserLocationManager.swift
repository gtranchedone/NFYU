//
//  UserLocationManager.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 02/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import Foundation
import CoreLocation

let UserLocationManagerErrorDomain = "UserLocationManagerErrorDomain"

enum UserLocationManagerResult {
    case success(Location)
    case error(NSError)
}

protocol UserLocationManager: AnyObject {
    
    var locationServicesEnabled: Bool { get }
    var didRequestAuthorization: Bool { get }
    
    // returns true if it asked for user authorization, false if the user was already prompted once
    @discardableResult func requestUserAuthorizationForUsingLocationServices(_ completionBlock: @escaping () -> ()) -> Bool
    @discardableResult func requestCurrentLocation(_ completionBlock: @escaping (UserLocationManagerResult) -> ())

}

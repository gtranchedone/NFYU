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

// NOTE: this really hasn't the best name. Need something better.
protocol UserLocationManager: AnyObject {

    var locationServicesEnabled: Bool { get }
    
    func requestUserAuthorizationForUsingLocationServices()
    func requestCurrentLocation(completionBlock: (NSError?, CLLocation?) -> ())

}

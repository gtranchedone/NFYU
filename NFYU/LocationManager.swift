//
//  LocationManager.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 02/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationManager {
    
    func locationServicesEnabled() -> Bool
    func requestCurrentLocation(completionBlock: (NSError?, CLLocation?) -> ())
    
}

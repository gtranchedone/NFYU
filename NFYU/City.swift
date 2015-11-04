//
//  City.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 03/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import Foundation
import CoreLocation

class City {
    
    let coordinate: CLLocationCoordinate2D
    let country: String
    let region: String?
    let name: String
    
    var displayableName: String {
        get {
            if let region = region {
                return "\(name), \(region)"
            }
            else {
                return "\(name), \(country)"
            }
        }
    }
    
    init(coordinate: CLLocationCoordinate2D, name: String, country: String, region: String? = nil) {
        self.coordinate = coordinate
        self.country = country
        self.region = region
        self.name = name
    }
    
}

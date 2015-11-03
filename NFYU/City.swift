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
    let name: String
    
    init(coordinate: CLLocationCoordinate2D, name: String, country: String) {
        self.coordinate = coordinate
        self.country = country
        self.name = name
    }
    
}

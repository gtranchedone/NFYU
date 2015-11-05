//
//  City.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 03/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import Foundation
import CoreLocation

class City: Equatable {
    
    let coordinate: CLLocationCoordinate2D
    let country: String
    let state: String?
    let city: String?
    let name: String?
    
    var displayableName: String {
        get {
            var placeName = name ?? city ?? ""
            if let name = name, city = city {
                if !name.containsString(city) {
                    placeName = "\(name), \(city)"
                }
            }
            if country == "United States" || country == "USA" {
                if let state = state {
                    return "\(placeName), \(state)"
                }
            }
            return "\(placeName), \(country)"
        }
    }
    
    init(coordinate: CLLocationCoordinate2D, name: String?, country: String, state: String? = nil, city: String? = nil) {
        self.coordinate = coordinate
        self.country = country
        self.state = state
        self.city = city ?? name
        self.name = name
    }
    
}

func ==(lhs: City, rhs: City) -> Bool {
    // !!!: this should probably be based only upon coordinates but different services may locate cities to different coordinates (small differences of course)
    return lhs.city == rhs.city && lhs.state == rhs.state && lhs.country == rhs.country
}

//
//  LocationInfo.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 06/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import Foundation

struct LocationInfo: Equatable {
    
    let id: String?
    let name: String?
    let city: String?
    let state: String?
    let country: String?
    
    init(id: String? = nil, name: String? = nil, city: String? = nil, state: String? = nil, country: String? = nil) {
        self.id = id
        self.name = name
        self.city = city
        self.state = state
        self.country = country
    }
    
}

func ==(lhs: LocationInfo, rhs: LocationInfo) -> Bool {
    return lhs.id == rhs.id
}

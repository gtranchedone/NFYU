//
//  Location.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 03/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import Foundation
import CoreLocation

extension CLLocationCoordinate2D: Equatable {
}

public func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
    return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
}

class Location: NSObject, NSCoding {
    
    var locationInfo: LocationInfo
    let coordinate: CLLocationCoordinate2D
    
    var forecasts: [Forecast] = []
    var forecastsForToday: [Forecast] {
        return forecasts.filter { (forecast) -> Bool in
            return Calendar.current.isDateInToday(forecast.date as Date)
        }
    }
    
    var isUserLocation: Bool = false
    
    var country: String? {
        return locationInfo.country
    }
    var state: String? {
        return locationInfo.state
    }
    var city: String? {
        return locationInfo.city ?? locationInfo.name
    }
    var name: String? {
        return locationInfo.name
    }
    
    var displayableName: String {
        var placeName = city ?? ""
        if let name = name, let city = city {
            if !name.contains(city) {
                placeName = "\(name), \(city)"
            }
        }
        if let country = country {
            if country == "United States" || country == "USA" {
                if let state = state {
                    return "\(placeName), \(state)"
                }
            }
            return "\(placeName), \(country)"
        }
        return placeName
    }
    
    override var hashValue: Int {
        return coordinate.longitude.hashValue
    }
    
    init(coordinate: CLLocationCoordinate2D, locationInfo: LocationInfo) {
        self.coordinate = coordinate
        self.locationInfo = locationInfo
    }
    
    convenience init(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        self.init(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
    }
    
    convenience init(coordinate: CLLocationCoordinate2D, name: String? = nil, country: String? = nil, state: String? = nil, city: String? = nil) {
        let locationInfo = LocationInfo(name: name, city: city, state: state, country: country)
        self.init(coordinate: coordinate, locationInfo: locationInfo)
    }
    
    // MARK: - NSCoding
    
    fileprivate enum NSCodingKeys: String {
        case Name = "name"
        case City = "city"
        case State = "state"
        case Country = "country"
        case Latitude = "latitude"
        case Longitude = "longitude"
    }
    
    convenience required init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObject(forKey: NSCodingKeys.Name.rawValue) as? String
        let city = aDecoder.decodeObject(forKey: NSCodingKeys.City.rawValue) as? String
        let state = aDecoder.decodeObject(forKey: NSCodingKeys.State.rawValue) as? String
        let country = aDecoder.decodeObject(forKey: NSCodingKeys.Country.rawValue) as? String
        let latitude = aDecoder.decodeDouble(forKey: NSCodingKeys.Latitude.rawValue)
        let longitude = aDecoder.decodeDouble(forKey: NSCodingKeys.Longitude.rawValue)
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.init(coordinate: coordinate, name: name, country: country, state: state, city: city)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: NSCodingKeys.Name.rawValue)
        aCoder.encode(city, forKey: NSCodingKeys.City.rawValue)
        aCoder.encode(state, forKey: NSCodingKeys.State.rawValue)
        aCoder.encode(country, forKey: NSCodingKeys.Country.rawValue)
        aCoder.encode(coordinate.latitude, forKey: NSCodingKeys.Latitude.rawValue)
        aCoder.encode(coordinate.longitude, forKey: NSCodingKeys.Longitude.rawValue)
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let object = object as? Location {
            return object == self
        }
        return false
    }
    
}

func ==(lhs: Location, rhs: Location) -> Bool {
    // !!!: this should probably be based only upon coordinates but different services may locate cities to different coordinates (small differences of course)
    return lhs.city == rhs.city && lhs.state == rhs.state && lhs.country == rhs.country && lhs.coordinate == rhs.coordinate
}

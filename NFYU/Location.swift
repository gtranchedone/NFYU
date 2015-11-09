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
        get {
            return forecasts.filter { (forecast) -> Bool in
                return NSCalendar.currentCalendar().isDateInToday(forecast.date)
            }
        }
    }
    
    var isUserLocation: Bool = false
    
    var country: String? {
        get { return locationInfo.country }
    }
    var state: String? {
        get { return locationInfo.state }
    }
    var city: String? {
        get { return locationInfo.city ?? locationInfo.name }
    }
    var name: String? {
        get { return locationInfo.name }
    }
    
    var displayableName: String {
        get {
            var placeName = city ?? ""
            if let name = name, city = city {
                if !name.containsString(city) {
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
    }
    
    override var hashValue: Int {
        get {
            return coordinate.longitude.hashValue
        }
    }
    
    init(coordinate: CLLocationCoordinate2D, locationInfo: LocationInfo) {
        self.coordinate = coordinate
        self.locationInfo = locationInfo
    }
    
    convenience init(coordinate: CLLocationCoordinate2D, name: String? = nil, country: String? = nil, state: String? = nil, city: String? = nil) {
        let locationInfo = LocationInfo(name: name, city: city, country: country, state: state)
        self.init(coordinate: coordinate, locationInfo: locationInfo)
    }
    
    // MARK: - NSCoding
    
    private enum NSCodingKeys: String {
        case Name = "name"
        case City = "city"
        case State = "state"
        case Country = "country"
        case Latitude = "latitude"
        case Longitude = "longitude"
    }
    
    convenience required init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObjectForKey(NSCodingKeys.Name.rawValue) as? String
        let city = aDecoder.decodeObjectForKey(NSCodingKeys.City.rawValue) as? String
        let state = aDecoder.decodeObjectForKey(NSCodingKeys.State.rawValue) as? String
        let country = aDecoder.decodeObjectForKey(NSCodingKeys.Country.rawValue) as? String
        let latitude = aDecoder.decodeDoubleForKey(NSCodingKeys.Latitude.rawValue)
        let longitude = aDecoder.decodeDoubleForKey(NSCodingKeys.Longitude.rawValue)
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.init(coordinate: coordinate, name: name, country: country, state: state, city: city)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: NSCodingKeys.Name.rawValue)
        aCoder.encodeObject(city, forKey: NSCodingKeys.City.rawValue)
        aCoder.encodeObject(state, forKey: NSCodingKeys.State.rawValue)
        aCoder.encodeObject(country, forKey: NSCodingKeys.Country.rawValue)
        aCoder.encodeDouble(coordinate.latitude, forKey: NSCodingKeys.Latitude.rawValue)
        aCoder.encodeDouble(coordinate.longitude, forKey: NSCodingKeys.Longitude.rawValue)
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
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

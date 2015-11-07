//
//  UserDefaults.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 01/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import Foundation

protocol UserDefaults: AnyObject {
    
    func objectForKey(defaultName: String) -> AnyObject?
    func setObject(value: AnyObject?, forKey defaultName: String)
    
    func boolForKey(defaultName: String) -> Bool
    func setBool(value: Bool, forKey defaultName: String)
    
}

struct UserDefaultsKeys {
    static let DidSetUpLocations = "com.gtranchedone.NFYU.DidSetUpLocations"
    static let FavouriteLocations = "com.gtranchedone.NFYU.FavouriteLocations"
}

extension UserDefaults {
    
    var didSetUpLocations: Bool {
        get {
            return boolForKey(UserDefaultsKeys.DidSetUpLocations)
        }
        set {
            setBool(newValue, forKey:UserDefaultsKeys.DidSetUpLocations)
        }
    }
    
    var favouriteLocations: [Location] {
        // NOTE: mapping necessary as NSUserDefaults can only store Plist data... probably this should be in an extension of NSUserDefaults, at least in part
        get {
            let locationsData = objectForKey(UserDefaultsKeys.FavouriteLocations) as? [NSData] ?? []
            return locationsData.map { (locationData) -> Location in
                return NSKeyedUnarchiver.unarchiveObjectWithData(locationData) as! Location
            }
        }
        set {
            let locationsData = newValue.map { (location) -> NSData in
                return NSKeyedArchiver.archivedDataWithRootObject(location)
            }
            setObject(locationsData, forKey: UserDefaultsKeys.FavouriteLocations)
        }
    }
    
}

extension NSUserDefaults : UserDefaults {}

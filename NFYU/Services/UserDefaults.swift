//
//  UserDefaults.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 01/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import Foundation

protocol UserDefaults: class {
    
    func object(forKey defaultName: String) -> Any?
    func set(_ value: Any?, forKey defaultName: String)
    
    func bool(forKey defaultName: String) -> Bool
    func set(_ value: Bool, forKey defaultName: String)
    
}

struct UserDefaultsKeys {
    static let DidSetUpLocations = "com.gtranchedone.NFYU.DidSetUpLocations"
    static let FavouriteLocations = "com.gtranchedone.NFYU.FavouriteLocations"
    static let UseFahrenheitDegrees = "com.gtranchedone.NFYU.UseFahrenheitDegrees"
}

extension UserDefaults {
    
    var didSetUpLocations: Bool {
        get {
            return bool(forKey: UserDefaultsKeys.DidSetUpLocations)
        }
        set {
            set(newValue, forKey:UserDefaultsKeys.DidSetUpLocations)
        }
    }
    
    var favouriteLocations: [Location] {
        // NOTE: mapping necessary as Foundation.UserDefaults can only store Plist data
        // Probably this logic to save Location data should be in an extension of UserDefaults
        get {
            let locationsData = object(forKey: UserDefaultsKeys.FavouriteLocations) as? [Data] ?? []
            return locationsData.map { (locationData) -> Location in
                return NSKeyedUnarchiver.unarchiveObject(with: locationData) as! Location
            }
        }
        set {
            let locationsData = newValue.map { (location) -> Data in
                return NSKeyedArchiver.archivedData(withRootObject: location)
            }
            set(locationsData as AnyObject?, forKey: UserDefaultsKeys.FavouriteLocations)
        }
    }
    
    var useFahrenheitDegrees: Bool {
        get {
            return bool(forKey: UserDefaultsKeys.UseFahrenheitDegrees)
        }
        set {
            set(newValue, forKey:UserDefaultsKeys.UseFahrenheitDegrees)
        }
    }
    
}

extension Foundation.UserDefaults: UserDefaults {}

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
    static let FavouriteCities = "com.gtranchedone.NFYU.FavouriteCities"
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
    
    var favouriteCities: [City] {
        get {
            return objectForKey(UserDefaultsKeys.FavouriteCities) as? [City] ?? []
        }
        set {
            setObject(newValue, forKey: UserDefaultsKeys.FavouriteCities)
        }
    }
    
}

extension NSUserDefaults : UserDefaults {}

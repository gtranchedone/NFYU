//
//  UserDefaults.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 01/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import Foundation

protocol UserDefaults: AnyObject {
    
    func boolForKey(defaultName: String) -> Bool
    func setBool(value: Bool, forKey defaultName: String)
    
}

struct UserDefaultsKeys {
    static let DidSetUpLocations = "com.gtranchedone.NFYU.DidSetUpLocations"
    static let CanUseUserLocation = "com.gtranchedone.NFYU.CanUseUserLocation"
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
    
    var canUseUserLocation: Bool {
        get {
            return boolForKey(UserDefaultsKeys.CanUseUserLocation)
        }
        set {
            setBool(newValue, forKey:UserDefaultsKeys.CanUseUserLocation)
        }
    }
    
}

extension NSUserDefaults : UserDefaults {}

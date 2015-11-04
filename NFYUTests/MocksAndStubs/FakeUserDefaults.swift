//
//  FakeUserDefaults.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 01/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import Foundation
@testable import NFYU

class FakeUserDefaults: NSObject, UserDefaults {

    private var dictionary = NSMutableDictionary()
    
    func objectForKey(defaultName: String) -> AnyObject? {
        return dictionary.objectForKey(defaultName)
    }
    
    func setObject(value: AnyObject?, forKey defaultName: String) {
        if let value = value {
            dictionary.setObject(value, forKey: defaultName)
        }
        else {
            dictionary.removeObjectForKey(defaultName)
        }
    }
    
    func setBool(value: Bool, forKey defaultName: String) {
        dictionary.setObject(NSNumber(bool: value), forKey: defaultName)
    }
    
    func boolForKey(defaultName: String) -> Bool {
        return dictionary.objectForKey(defaultName)?.boolValue ?? false
    }
    
}

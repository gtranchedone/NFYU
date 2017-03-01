//
//  FakeUserDefaults.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 01/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import Foundation
@testable import NFYU

class FakeUserDefaults: NFYU.UserDefaults {

    private var dictionary = NSMutableDictionary()
    
    func object(forKey defaultName: String) -> Any? {
        return dictionary.object(forKey: defaultName)
    }
    
    func set(_ value: Any?, forKey defaultName: String) {
        if let value = value {
            dictionary.setObject(value, forKey: defaultName as NSCopying)
        }
        else {
            dictionary.removeObject(forKey: defaultName)
        }
    }
    
    func set(_ value: Bool, forKey defaultName: String) {
        dictionary.setObject(NSNumber(value: value as Bool), forKey: defaultName as NSCopying)
    }
    
    func bool(forKey defaultName: String) -> Bool {
        return (dictionary.object(forKey: defaultName) as AnyObject).boolValue ?? false
    }
    
}

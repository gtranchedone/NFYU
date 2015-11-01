//
//  UserDefaults.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 01/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import Foundation

struct UserDefaultsKeys {
    static let DidPresentIntro = "com.gtranchedone.NFYU.DidPresentIntro"
}

protocol UserDefaults: AnyObject {
    
    func boolForKey(defaultName: String) -> Bool
    func setBool(value: Bool, forKey defaultName: String)
    
}

extension NSUserDefaults : UserDefaults {}

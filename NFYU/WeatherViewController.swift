//
//  WeatherViewController.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 01/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import UIKit

class WeatherViewController: BaseViewController {

    struct SegueIdentifier {
        static let Intro = "IntroSegueIdentifier"
    }
    
    var userDefaults: UserDefaults?
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let didPresentIntro = userDefaults?.boolForKey(UserDefaultsKeys.DidPresentIntro) ?? false
        if !didPresentIntro {
            performSegueWithIdentifier(SegueIdentifier.Intro, sender: self)
        }
    }

}

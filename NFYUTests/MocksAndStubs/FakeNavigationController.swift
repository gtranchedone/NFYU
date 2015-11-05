//
//  FakeNavigationController.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 05/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import UIKit

class FakeNavigationController: UINavigationController {
    
    private(set) var didAttemptPoppingViewController = false
    
    override func popViewControllerAnimated(animated: Bool) -> UIViewController? {
        didAttemptPoppingViewController = true
        return nil
    }
    
}

//
//  CitySearchViewController.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 04/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import UIKit

protocol CitySearchViewControllerDelegate: AnyObject {
    
    func citySearchViewController(viewController: CitySearchViewController, didFinishWithCity city: City?)
    
}

class CitySearchViewController: UIViewController {

    var delegate: CitySearchViewControllerDelegate?
    
}

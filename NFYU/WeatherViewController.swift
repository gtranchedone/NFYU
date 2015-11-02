//
//  WeatherViewController.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 01/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import UIKit

class WeatherViewController: BaseViewController {

    var userDefaults: UserDefaults?
    
    @IBOutlet weak var initialSetupView: UIView!
    @IBOutlet weak var backgroundMessageLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setInitialViewState()
    }
    
    private func setInitialViewState() {
        pageControl.numberOfPages = 0
        activityIndicator.hidden = true
        backgroundMessageLabel.hidden = true
        initialSetupView.hidden = userDefaults?.didSetUpLocations ?? false
    }

}

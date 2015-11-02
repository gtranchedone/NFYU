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
    var locationManager: LocationManager?
    
    @IBOutlet weak var initialSetupView: SetupView!
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
        backgroundMessageLabel.hidden = true
        initialSetupView.hidden = userDefaults?.didSetUpLocations ?? false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateWithCurrentLocation()
    }
    
    func updateWithCurrentLocation() {
        let canUseUserLocation = userDefaults?.canUseUserLocation ?? false
        if canUseUserLocation {
            activityIndicator.startAnimating()
            locationManager?.requestCurrentLocation() { [weak self] error, location in
                self?.activityIndicator.stopAnimating()
                if let error = error {
                    self?.backgroundMessageLabel.text = error.localizedDescription
                    self?.backgroundMessageLabel.hidden = false
                }
            }
        }
    }
    
    @IBAction func useCurrentLocation() {
        userDefaults?.canUseUserLocation = true
        initialSetupView.hidden = true
        updateWithCurrentLocation()
    }
    
    @IBAction func selectCities() {
        initialSetupView.hidden = true
    }
    
}

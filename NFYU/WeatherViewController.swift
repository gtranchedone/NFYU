//
//  WeatherViewController.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 01/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import UIKit

class WeatherViewController: BaseViewController, SettingsViewControllerDelegate {

    struct SegueIdentifiers {
        static let Settings = "SettingsSegueIdentifier"
    }
    
    var userDefaults: UserDefaults?
    var locationManager: LocationFinder?
    
    @IBOutlet weak var initialSetupView: SetupView!
    @IBOutlet weak var backgroundMessageLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var settingsButton: UIButton!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setInitialViewState()
    }
    
    private func setInitialViewState() {
        pageControl.numberOfPages = 0
        backgroundMessageLabel.hidden = true
        initialSetupView.hidden = userDefaults?.didSetUpLocations ?? false
        settingsButton.hidden = !initialSetupView.hidden
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateWithCurrentLocation()
    }
    
    // MARK: - Other Business Logic
    
    func updateWithCurrentLocation() {
        let canUseUserLocation = locationManager?.locationServicesEnabled() ?? false
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
    
    func didSetupLocations() {
        userDefaults?.didSetUpLocations = true
        initialSetupView.hidden = true
        settingsButton.hidden = false
    }
    
    // MARK: - User Actions Handling
    
    @IBAction func useCurrentLocation() {
        didSetupLocations()
        updateWithCurrentLocation()
    }
    
    @IBAction func selectCities() {
        initialSetupView.hidden = true
        performSegueWithIdentifier(SegueIdentifiers.Settings, sender: initialSetupView)
    }
    
    @IBAction func showSettings() {
        performSegueWithIdentifier(SegueIdentifiers.Settings, sender: settingsButton)
    }
    
    // MARK: SettingsViewControllerDelegate
    
    func settingsViewControllerDidFinish(viewController: SettingsViewController) {
        var hasValidData = false
        if let userDefaults = userDefaults {
            hasValidData = userDefaults.favouriteCities.count > 0
        }
        if let locationManager = locationManager {
            hasValidData = hasValidData || locationManager.locationServicesEnabled()
        }
        
        userDefaults?.didSetUpLocations = hasValidData
        if hasValidData {
            initialSetupView.hidden = true
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    // MARK: Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueIdentifiers.Settings && sender === initialSetupView {
            let destinationViewController = segue.destinationViewController as? UINavigationController
            let settingsViewController = destinationViewController?.topViewController as? SettingsViewController
            settingsViewController?.displayOnlyFavouriteCities = true
            settingsViewController?.delegate = self
        }
    }
    
}

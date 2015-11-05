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
    
    var apiClient: APIClient?
    var userDefaults: UserDefaults?
    var locationManager: LocationFinder?
    
    private(set) var locations: [Location] = []
    
    @IBOutlet weak var initialSetupView: SetupView!
    @IBOutlet weak var backgroundMessageLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var settingsButton: UIButton!
    
    // MARK: - View Lifecycle
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLocations()
        setInitialViewState()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidBecomeActive", name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    private func setInitialViewState() {
        pageControl.numberOfPages = 0
        backgroundMessageLabel.hidden = true
        initialSetupView.hidden = userDefaults?.didSetUpLocations ?? false
        settingsButton.hidden = !initialSetupView.hidden
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateCurrentLocationIfPossible()
        loadForecastsForAllLocations()
    }
    
    // MARK: - Other Business Logic
    
    func applicationDidBecomeActive() {
        updateCurrentLocationIfPossible()
        updateLocations()
        loadForecastsForAllLocations()
    }
    
    private func updateLocations() {
        let currentLocation = self.currentLocation()
        var newLocations = userDefaults?.favouriteLocations ?? []
        if let currentLocation = currentLocation {
            newLocations.insert(currentLocation, atIndex: 0)
        }
        locations = newLocations
    }
    
    private func currentLocation() -> Location? {
        return locations.filter({ (location) -> Bool in
            return location.isUserLocation
        }).first
    }
    
    func updateCurrentLocationIfPossible() {
        let canUseUserLocation = locationManager?.locationServicesEnabled() ?? false
        if canUseUserLocation {
            activityIndicator.startAnimating()
            locationManager?.requestCurrentLocation() { [weak self] error, location in
                self?.activityIndicator.stopAnimating()
                if let error = error {
                    self?.backgroundMessageLabel.text = error.localizedDescription
                    self?.backgroundMessageLabel.hidden = false
                }
                else if let userLocation = location {
                    var currentLocation = self?.currentLocation()
                    if let currentLocation = currentLocation {
                        self?.locations.removeAtIndex(self!.locations.indexOf(currentLocation)!)
                    }
                    currentLocation = Location(coordinate: userLocation.coordinate)
                    currentLocation!.isUserLocation = true
                    self?.locations.insert(currentLocation!, atIndex: 0)
                    self?.loadForecastsForAllLocations()
                }
            }
        }
        else {
            backgroundMessageLabel.text = hasCities() ? nil : NSLocalizedString("USE_OF_LOCATION_SERVICES_NOT_AUTHORIZED", comment: "")
        }
    }
    
    func didSetupLocations() {
        userDefaults?.didSetUpLocations = true
        initialSetupView.hidden = true
        settingsButton.hidden = false
    }
    
    // MARK: - Fetching Forecasts
    
    private func loadForecastsForAllLocations() {
        for location in locations {
            fetchForecastsForLocation(location)
        }
    }
    
    private func fetchForecastsForLocation(location: Location) {
        apiClient?.fetchForecastsForLocationWithCoordinate(location.coordinate) { (error, forecasts, locationInfo) -> () in
            // TODO: do something here
        }
    }
    
    // MARK: - User Actions Handling
    
    @IBAction func useCurrentLocation() {
        didSetupLocations()
        updateCurrentLocationIfPossible()
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
        var hasValidData = hasCities()
        if let locationManager = locationManager {
            hasValidData = hasValidData || locationManager.locationServicesEnabled()
        }
        userDefaults?.didSetUpLocations = hasValidData
        if hasValidData {
            initialSetupView.hidden = true
            dismissViewControllerAnimated(true, completion: nil)
        }
        updateLocations()
        collectionView.reloadData()
    }
    
    // MARK: Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueIdentifiers.Settings {
            let destinationViewController = segue.destinationViewController as? UINavigationController
            let settingsViewController = destinationViewController?.topViewController as? SettingsViewController
            settingsViewController?.userDefaults = userDefaults
            settingsViewController?.delegate = self
        }
    }
    
    // MARK: Helpers
    
    func hasCities() -> Bool {
        return userDefaults?.favouriteLocations.count > 0
    }
    
}

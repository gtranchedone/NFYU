//
//  WeatherViewController.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 01/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherViewController: BaseViewController, SettingsViewControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    enum SegueIdentifiers: String {
        case Settings = "SettingsSegueIdentifier"
    }
    
    var apiClient: APIClient?
    var userDefaults: UserDefaults?
    var locationManager: UserLocationManager?
    
    private(set) var locations: [Location] = [] {
        didSet {
            pageControl.numberOfPages = collectionView(collectionView, numberOfItemsInSection: 0)
            collectionView.reloadData()
        }
    }
    
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
        let notificationName = UIApplicationDidBecomeActiveNotification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidBecomeActive", name: notificationName, object: nil)
    }
    
    private func setInitialViewState() {
        backgroundMessageLabel.hidden = true
        initialSetupView.hidden = userDefaults?.didSetUpLocations ?? false
        settingsButton.hidden = !initialSetupView.hidden
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateCurrentLocationIfPossible()
        loadForecastsForAllLocations()
    }
    
    // MARK: - App Events
    
    func applicationDidBecomeActive() {
        updateCurrentLocationIfPossible()
        updateLocations()
        loadForecastsForAllLocations()
    }
    
    // MARK: - Location Updates
    
    private func updateLocations() {
        let currentLocation = self.currentLocation()
        var newLocations = userDefaults?.favouriteLocations ?? []
        if let currentLocation = currentLocation {
            newLocations.insert(currentLocation, atIndex: 0)
        }
        locations = newLocations
    }
    
    private func currentLocation() -> Location? {
        guard locationManager?.locationServicesEnabled == true else { return nil }
        guard userDefaults?.didSetUpLocations == true else { return nil }
        var location = locations.filter({ (location) -> Bool in
            return location.isUserLocation
        }).first
        if location == nil {
            location = Location(coordinate: CLLocationCoordinate2D())
            location?.isUserLocation = true
        }
        return location
    }
    
    func updateCurrentLocationIfPossible() {
        let didSetUpLocations = userDefaults?.didSetUpLocations == true
        let canUseUserLocation = locationManager?.locationServicesEnabled == true
        if didSetUpLocations && canUseUserLocation {
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
                        if self?.locations.contains(currentLocation) == true {
                            self?.locations.removeAtIndex(self!.locations.indexOf(currentLocation)!)
                        }
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
    
    func loadForecastsForAllLocations() {
        for location in locations {
            fetchForecastsForLocation(location)
        }
    }
    
    func fetchForecastsForLocation(location: Location) {
        // TODO: don't load if last successful update is < 4h ago
        guard !(location.isUserLocation && location.coordinate == CLLocationCoordinate2D()) else { return }
        apiClient?.fetchForecastsForLocationWithCoordinate(location.coordinate) { [weak self] (error, forecasts, locationInfo) -> () in
            // don't display any error message in case of error: showing the forecast template will suffice for now
            var needsReload = false
            if let locationInfo = locationInfo {
                // update the location info only if the information about the location's city is missing
                // in most cases this operation will only be performed to update the user location info
                location.locationInfo = location.locationInfo.city != nil ? location.locationInfo : locationInfo
                needsReload = true
            }
            if let forecasts = forecasts {
                location.forecasts = forecasts
                needsReload = true
            }
            if needsReload {
                self?.collectionView?.reloadData()
            }
        }
    }
    
    // MARK: - User Actions Handling
    
    @IBAction func useCurrentLocation() {
        didSetupLocations()
        locationManager?.requestUserAuthorizationForUsingLocationServices { [weak self] () -> () in
            self?.updateCurrentLocationIfPossible()
        }
    }
    
    @IBAction func selectCities() {
        settingsButton.hidden = false
        initialSetupView.hidden = true
        performSegueWithIdentifier(SegueIdentifiers.Settings.rawValue, sender: initialSetupView)
    }
    
    @IBAction func showSettings() {
        performSegueWithIdentifier(SegueIdentifiers.Settings.rawValue, sender: settingsButton)
    }
    
    // MARK: SettingsViewControllerDelegate
    
    func settingsViewControllerDidFinish(viewController: SettingsViewController) {
        var hasValidData = hasCities()
        if let locationManager = locationManager {
            hasValidData = hasValidData || locationManager.locationServicesEnabled
        }
        userDefaults?.didSetUpLocations = hasValidData
        if hasValidData {
            initialSetupView.hidden = true
            dismissViewControllerAnimated(true, completion: nil)
        }
        updateLocations()
    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        guard userDefaults?.didSetUpLocations == true else { return 0 }
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let canUseLocationServices = locationManager?.locationServicesEnabled ?? false
        let numberOfFavouriteCities = userDefaults?.favouriteLocations.count ?? 0
        if canUseLocationServices {
            return numberOfFavouriteCities + 1
        }
        return numberOfFavouriteCities
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let location = locations[indexPath.item]
        let viewModel = LocationViewModel(userDefaults: userDefaults)
        return viewModel.collectionViewCellForLocation(location, collectionView: collectionView, indexPath: indexPath)
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let currentPage = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        pageControl.currentPage = currentPage
    }
    
    // MARK: Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueIdentifiers.Settings.rawValue {
            let destinationViewController = segue.destinationViewController as? UINavigationController
            let settingsViewController = destinationViewController?.topViewController as? SettingsViewController
            settingsViewController?.locationManager = locationManager
            settingsViewController?.userDefaults = userDefaults
            settingsViewController?.delegate = self
        }
    }
    
    // MARK: Helpers
    
    func hasCities() -> Bool {
        return userDefaults?.favouriteLocations.count > 0
    }
    
}

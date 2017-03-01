//
//  WeatherViewController.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 01/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import UIKit
import CoreLocation

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class WeatherViewController: BaseViewController, SettingsViewControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    enum SegueIdentifiers: String {
        case Settings = "SettingsSegueIdentifier"
    }
    
    var apiClient: APIClient?
    var userDefaults: UserDefaults?
    var locationManager: UserLocationManager?
    
    fileprivate(set) var locations: [Location] = [] {
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
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLocations()
        setInitialViewState()
        let notificationName = NSNotification.Name.UIApplicationDidBecomeActive
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(WeatherViewController.applicationDidBecomeActive),
                                               name: notificationName,
                                               object: nil)
    }
    
    fileprivate func setInitialViewState() {
        backgroundMessageLabel.isHidden = true
        initialSetupView.isHidden = userDefaults?.didSetUpLocations ?? false
        settingsButton.isHidden = !initialSetupView.isHidden
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
    
    fileprivate func updateLocations() {
        let currentLocation = self.currentLocation()
        var newLocations = userDefaults?.favouriteLocations ?? []
        if let currentLocation = currentLocation {
            newLocations.insert(currentLocation, at: 0)
        }
        locations = newLocations
    }
    
    fileprivate func currentLocation() -> Location? {
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
            locationManager?.requestCurrentLocation() { [weak self] result in
                guard let strongSelf = self else { return }
                strongSelf.activityIndicator.stopAnimating()
                switch result {
                case .error(let error):
                    strongSelf.backgroundMessageLabel.text = error.localizedDescription
                    strongSelf.backgroundMessageLabel.isHidden = false
                
                case .success(let userLocation):
                    var currentLocation = self?.currentLocation()
                    if let currentLocation = currentLocation {
                        if strongSelf.locations.contains(currentLocation) == true {
                            strongSelf.locations.remove(at: self!.locations.index(of: currentLocation)!)
                        }
                    }
                    currentLocation = Location(coordinate: userLocation.coordinate)
                    currentLocation!.isUserLocation = true
                    strongSelf.locations.insert(currentLocation!, at: 0)
                    strongSelf.loadForecastsForAllLocations()
                }
            }
        }
        else {
            backgroundMessageLabel.text = hasCities() ? nil : NSLocalizedString("USE_OF_LOCATION_SERVICES_NOT_AUTHORIZED", comment: "")
        }
    }
    
    func didSetupLocations() {
        userDefaults?.didSetUpLocations = true
        initialSetupView.isHidden = true
        settingsButton.isHidden = false
    }
    
    // MARK: - Fetching Forecasts
    
    func loadForecastsForAllLocations() {
        for location in locations {
            fetchForecastsForLocation(location)
        }
    }
    
    func fetchForecastsForLocation(_ location: Location, completion: (() -> ())? = nil) {
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
            completion?()
        }
    }
    
    // MARK: - User Actions Handling
    
    @IBAction func useCurrentLocation() {
        didSetupLocations()
        let _ = locationManager?.requestUserAuthorizationForUsingLocationServices { [weak self] () -> () in
            self?.updateCurrentLocationIfPossible()
        }
    }
    
    @IBAction func selectCities() {
        settingsButton.isHidden = false
        initialSetupView.isHidden = true
        performSegue(withIdentifier: SegueIdentifiers.Settings.rawValue, sender: initialSetupView)
    }
    
    @IBAction func showSettings() {
        performSegue(withIdentifier: SegueIdentifiers.Settings.rawValue, sender: settingsButton)
    }
    
    // MARK: SettingsViewControllerDelegate
    
    func settingsViewControllerDidFinish(_ viewController: SettingsViewController) {
        var hasValidData = hasCities()
        if let locationManager = locationManager {
            hasValidData = hasValidData || locationManager.locationServicesEnabled
        }
        userDefaults?.didSetUpLocations = hasValidData
        if hasValidData {
            initialSetupView.isHidden = true
            dismiss(animated: true, completion: nil)
        }
        updateLocations()
    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard userDefaults?.didSetUpLocations == true else { return 0 }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let canUseLocationServices = locationManager?.locationServicesEnabled ?? false
        let numberOfFavouriteCities = userDefaults?.favouriteLocations.count ?? 0
        if canUseLocationServices {
            return numberOfFavouriteCities + 1
        }
        return numberOfFavouriteCities
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let location = locations[indexPath.item]
        let viewModel = LocationViewModel(userDefaults: userDefaults)
        return viewModel.collectionViewCellForLocation(location, collectionView: collectionView, indexPath: indexPath)
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentPage = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        pageControl.currentPage = currentPage
    }
    
    // MARK: Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifiers.Settings.rawValue {
            let destinationViewController = segue.destination as? UINavigationController
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

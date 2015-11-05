//
//  CitySearchViewController.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 04/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import UIKit
import CoreLocation

protocol CitySearchViewControllerDelegate: AnyObject {
    
    func citySearchViewController(viewController: CitySearchViewController, didFinishWithLocation location: Location?)
    
}

// TODO: new API in iOS 7 or 8 improves UISearchController to make it a UIViewController. Use it.
class CitySearchViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {

    private enum CellIdentifiers: String {
        case CitySearchResultCell = "CitySearchResultCell"
    }
    
    var geocoder: CLGeocoder = CLGeocoder()
    var delegate: CitySearchViewControllerDelegate?
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    private var locations: [Location] = []
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("CITY_SEARCH_VIEW_TITLE", comment: "")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.becomeFirstResponder()
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        guard searchText.characters.count > 1 else { return }
        if geocoder.geocoding {
            geocoder.cancelGeocode()
        }
        // TODO: CLGeocoder still doesn't give great results. Move to Google Places API -> change geocoder to protocol, extend CLGeocoder and create GoogleGeocoder
        geocoder.geocodeAddressString(searchText) { [weak self] (placemarks, error) -> Void in
            if let placemarks = placemarks {
                self?.locations = placemarks.map { (placemark) -> Location in
                    let placeName = placemark.name ?? placemark.subLocality
                    let cityName = placemark.locality
                    let regionName = placemark.administrativeArea
                    let countryName = placemark.country
                    return Location(coordinate: placemark.location!.coordinate, name: placeName, country: countryName, state: regionName, city: cityName)
                }
                self?.tableView.reloadData()
            }
            else {
                self?.locations = []
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifiers.CitySearchResultCell.rawValue, forIndexPath: indexPath)
        let city = locations[indexPath.row]
        cell.textLabel?.text = city.displayableName
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delegate?.citySearchViewController(self, didFinishWithLocation: locations[indexPath.row])
    }
    
}

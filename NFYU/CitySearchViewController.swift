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
    
    func citySearchViewController(_ viewController: CitySearchViewController, didFinishWithLocation location: Location?)
    
}

// TODO: new API in iOS 7 or 8 improves UISearchController to make it a UIViewController. Use it.
class CitySearchViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {

    fileprivate enum CellIdentifiers: String {
        case CitySearchResultCell = "CitySearchResultCell"
    }
    
    var geocoder: CLGeocoder = CLGeocoder()
    var delegate: CitySearchViewControllerDelegate?
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var locations: [Location] = []
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("CITY_SEARCH_VIEW_TITLE", comment: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.becomeFirstResponder()
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard searchText.characters.count > 1 else { return }
        if geocoder.isGeocoding {
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.CitySearchResultCell.rawValue, for: indexPath)
        let city = locations[indexPath.row]
        cell.textLabel?.text = city.displayableName
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.citySearchViewController(self, didFinishWithLocation: locations[indexPath.row])
    }
    
}

//
//  SettingsViewController.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 03/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import UIKit

protocol SettingsViewControllerDelegate: AnyObject {
    
    func settingsViewControllerDidFinish(_ viewController: SettingsViewController)
    
}

// TODO: add switch for enabling user location usage

let kSectionForUserSettings = 0

class SettingsViewController: BaseTableViewController, CitySearchViewControllerDelegate, SwitchTableViewCellDelegate {
    
    enum Segues: String {
        case AddLocationSegue = "AddCitySegue"
    }
    
    enum UserSettings {
        case locationServicesEnabled
        case useFahrenheitDegrees
    }
    
    enum CellIdentifiers: String {
        case SwitchCell = "SwitchCell"
        case AddCityCell = "AddCityCell"
        case SimpleCityCell = "SimpleCityCell"
    }
    
    var delegate: SettingsViewControllerDelegate?
    var locationManager: UserLocationManager?
    var userDefaults: UserDefaults?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setEditing(false, animated: false)
        navigationItem.leftBarButtonItem = editButtonItem
        title = NSLocalizedString("SETTINGS_TITLE", comment: "")
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if editing {
            navigationItem.rightBarButtonItem = nil
        }
        else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(SettingsViewController.finish))
        }
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == kSectionForUserSettings {
            return 2
        }
        let numberOfLocations = (userDefaults?.favouriteLocations.count ?? 0)
        return numberOfLocations + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        let cellIdentifier: String
        let rowTitle: String
        if indexPath.section == kSectionForUserSettings {
            cellIdentifier = CellIdentifiers.SwitchCell.rawValue
            let switchCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SwitchTableViewCell
            
            if indexPath.row == 0 {
                switchCell.textLabel?.text = NSLocalizedString("TOGGLE_USER_LOCATION_ENABLED", comment: "")
                switchCell.switchControl.isOn = locationManager?.locationServicesEnabled ?? false
            }
            else {
                switchCell.textLabel?.text = NSLocalizedString("USE_FAHRENHEIT_DEGREES", comment: "")
                switchCell.switchControl.isOn = userDefaults?.useFahrenheitDegrees ?? false
            }
            
            switchCell.delegate = self
            cell = switchCell
        }
        else {
            if isAddCityIndexPath(indexPath) {
                cellIdentifier = CellIdentifiers.AddCityCell.rawValue
                rowTitle = NSLocalizedString("ADD_CITY_CELL_TITLE", comment: "")
            }
            else {
                cellIdentifier = CellIdentifiers.SimpleCityCell.rawValue
                let city = locationAtIndexPath(indexPath)
                rowTitle = city.displayableName
            }
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            cell.textLabel?.text = rowTitle
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return !isAddCityIndexPath(indexPath) && indexPath.section != kSectionForUserSettings
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return self.tableView(tableView, canEditRowAt:indexPath) ? .delete : .none
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if let userDefaults = userDefaults {
            var newCities = userDefaults.favouriteLocations
            newCities.remove(at: indexPath.row - 1)
            userDefaults.favouriteLocations = newCities
        }
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isAddCityIndexPath(indexPath) {
            performSegue(withIdentifier: Segues.AddLocationSegue.rawValue, sender: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return !isAddCityIndexPath(indexPath)
    }
    
    override func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        return isAddCityIndexPath(proposedDestinationIndexPath) ? sourceIndexPath : proposedDestinationIndexPath
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard sourceIndexPath != destinationIndexPath else { return }
        guard !isAddCityIndexPath(sourceIndexPath) && !isAddCityIndexPath(destinationIndexPath) else { return }
        if let userDefaults = userDefaults {
            var locations = userDefaults.favouriteLocations
            guard sourceIndexPath.row <= locations.count && destinationIndexPath.row <= locations.count else { return }
            
            let locationToMove = locations.remove(at: sourceIndexPath.row - 1)
            locations.insert(locationToMove, at: destinationIndexPath.row - 1)
            userDefaults.favouriteLocations = locations
        }
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.AddLocationSegue.rawValue {
            let citySearchViewController = segue.destination as? CitySearchViewController
            citySearchViewController?.delegate = self
        }
    }
    
    // MARK: - CitySearchViewControllerDelegate
    
    func citySearchViewController(_ viewController: CitySearchViewController, didFinishWithLocation location: Location?) {
        if let location = location {
            if let userDefaults = userDefaults {
                var newLocations = userDefaults.favouriteLocations
                newLocations.append(location)
                userDefaults.favouriteLocations = newLocations
                let newIndexPath = IndexPath(row: userDefaults.favouriteLocations.count, section: 1)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        }
        let _ = navigationController?.popViewController(animated: true)
    }
    
    // MARK: - SwitchTableViewCellDelegate
    
    func switchCellDidChangeSwitchValue(_ cell: SwitchTableViewCell) {
        let indexPathOfCell = tableView!.indexPath(for: cell)
        if indexPathOfCell!.row == 0 {
            guard locationManager != nil else { return }
            if cell.switchControl.isOn {
                if !(locationManager!.requestUserAuthorizationForUsingLocationServices({})) {
                    let title = NSLocalizedString("INSTRUCTIONS_FOR_ENABLING_USE_OF_DEVICE_LOCATION_ALERT_TITLE", comment: "")
                    let message = NSLocalizedString("INSTRUCTIONS_FOR_ENABLING_USE_OF_DEVICE_LOCATION_ALERT_MESSAGE", comment: "")
                    presentAlertWithTitle(title, message: message)
                    cell.switchControl.isOn = false
                }
            }
            else {
                let title = NSLocalizedString("INSTRUCTIONS_FOR_DISABLING_USE_OF_DEVICE_LOCATION_ALERT_TITLE", comment: "")
                let message = NSLocalizedString("INSTRUCTIONS_FOR_DISABLING_USE_OF_DEVICE_LOCATION_ALERT_MESSAGE", comment: "")
                presentAlertWithTitle(title, message: message)
                cell.switchControl.isOn = true
            }
        }
        else {
            userDefaults?.useFahrenheitDegrees = cell.switchControl.isOn
        }
    }
    
    // MARK: - Other
    
    func finish() {
        delegate?.settingsViewControllerDidFinish(self)
    }
    
    func isAddCityIndexPath(_ indexPath: IndexPath) -> Bool {
        return indexPath.row == 0 && indexPath.section != kSectionForUserSettings
    }
    
    fileprivate func locationAtIndexPath(_ indexPath: IndexPath) -> Location {
        let locations = userDefaults!.favouriteLocations
        return locations[indexPath.row - 1]
    }
    
    fileprivate func presentAlertWithTitle(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("ALERT_BUTTON_DISMISS", comment: ""), style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}

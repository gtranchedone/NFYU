//
//  SettingsViewController.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 03/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import UIKit

protocol SettingsViewControllerDelegate: AnyObject {
    
    func settingsViewControllerDidFinish(viewController: SettingsViewController)
    
}

// TODO: add switch for enabling user location usage

let kSectionForUserSettings = 0

class SettingsViewController: BaseTableViewController, CitySearchViewControllerDelegate, SwitchTableViewCellDelegate {
    
    enum Segues: String {
        case AddLocationSegue = "AddCitySegue"
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
        navigationItem.leftBarButtonItem = editButtonItem()
        title = NSLocalizedString("SETTINGS_TITLE", comment: "")
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if editing {
            navigationItem.rightBarButtonItem = nil
        }
        else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "finish")
        }
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == kSectionForUserSettings {
            return 1
        }
        let numberOfLocations = (userDefaults?.favouriteLocations.count ?? 0)
        return numberOfLocations + 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        let cellIdentifier: String
        let rowTitle: String
        if indexPath.section == kSectionForUserSettings {
            cellIdentifier = CellIdentifiers.SwitchCell.rawValue
            let switchCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! SwitchTableViewCell
            switchCell.textLabel?.text = NSLocalizedString("TOGGLE_USER_LOCATION_ENABLED", comment: "")
            switchCell.switchControl.on = locationManager?.locationServicesEnabled ?? false
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
            cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
            cell.textLabel?.text = rowTitle
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return !isAddCityIndexPath(indexPath) && indexPath.section != kSectionForUserSettings
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return self.tableView(tableView, canEditRowAtIndexPath:indexPath) ? .Delete : .None
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if let userDefaults = userDefaults {
            var newCities = userDefaults.favouriteLocations
            newCities.removeAtIndex(indexPath.row - 1)
            userDefaults.favouriteLocations = newCities
        }
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if isAddCityIndexPath(indexPath) {
            performSegueWithIdentifier(Segues.AddLocationSegue.rawValue, sender: indexPath)
        }
    }
    
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return !isAddCityIndexPath(indexPath)
    }
    
    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        guard sourceIndexPath != destinationIndexPath else { return }
        guard !isAddCityIndexPath(sourceIndexPath) && !isAddCityIndexPath(destinationIndexPath) else { return }
        if let userDefaults = userDefaults {
            var locations = userDefaults.favouriteLocations
            guard sourceIndexPath.row <= locations.count && destinationIndexPath.row <= locations.count else { return }
            
            let locationToMove = locations.removeAtIndex(sourceIndexPath.row - 1)
            locations.insert(locationToMove, atIndex: destinationIndexPath.row - 1)
            userDefaults.favouriteLocations = locations
        }
    }
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Segues.AddLocationSegue.rawValue {
            let citySearchViewController = segue.destinationViewController as? CitySearchViewController
            citySearchViewController?.delegate = self
        }
    }
    
    // MARK: - CitySearchViewControllerDelegate
    
    func citySearchViewController(viewController: CitySearchViewController, didFinishWithLocation location: Location?) {
        if let location = location {
            if let userDefaults = userDefaults {
                var newLocations = userDefaults.favouriteLocations
                newLocations.append(location)
                userDefaults.favouriteLocations = newLocations
                let newIndexPath = NSIndexPath(forRow: userDefaults.favouriteLocations.count, inSection: 1)
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Automatic)
            }
        }
        navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - SwitchTableViewCellDelegate
    
    func switchCellDidChangeSwitchValue(cell: SwitchTableViewCell) {
        guard locationManager != nil else { return }
        if cell.switchControl.on {
            if !(locationManager!.requestUserAuthorizationForUsingLocationServices()) {
                let title = NSLocalizedString("INSTRUCTIONS_FOR_ENABLING_USE_OF_DEVICE_LOCATION_ALERT_TITLE", comment: "")
                let message = NSLocalizedString("INSTRUCTIONS_FOR_ENABLING_USE_OF_DEVICE_LOCATION_ALERT_MESSAGE", comment: "")
                presentAlertWithTitle(title, message: message)
                cell.switchControl.on = false
            }
        }
        else {
            let title = NSLocalizedString("INSTRUCTIONS_FOR_DISABLING_USE_OF_DEVICE_LOCATION_ALERT_TITLE", comment: "")
            let message = NSLocalizedString("INSTRUCTIONS_FOR_DISABLING_USE_OF_DEVICE_LOCATION_ALERT_MESSAGE", comment: "")
            presentAlertWithTitle(title, message: message)
            cell.switchControl.on = true
        }
    }
    
    // MARK: - Other
    
    func finish() {
        delegate?.settingsViewControllerDidFinish(self)
    }
    
    func isAddCityIndexPath(indexPath: NSIndexPath) -> Bool {
        return indexPath.row == 0 && indexPath.section != kSectionForUserSettings
    }
    
    private func locationAtIndexPath(indexPath: NSIndexPath) -> Location {
        let locations = userDefaults!.favouriteLocations
        return locations[indexPath.row - 1]
    }
    
    private func presentAlertWithTitle(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("ALERT_BUTTON_DISMISS", comment: ""), style: .Cancel, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
}

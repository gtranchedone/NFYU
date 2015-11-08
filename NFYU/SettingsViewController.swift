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

// TODO: allow sorting cities
// TODO: add switch for enabling user location usage

class SettingsViewController: BaseTableViewController, CitySearchViewControllerDelegate {
    
    enum Segues: String {
        case AddLocationSegue = "AddCitySegue"
    }
    
    enum CellIdentifiers: String {
        case AddCityCell = "AddCityCell"
        case SimpleCityCell = "SimpleCityCell"
    }
    
    var delegate: SettingsViewControllerDelegate?
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
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + (userDefaults?.favouriteLocations.count ?? 0)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier: String
        let rowTitle: String
        if isAddCityIndexPath(indexPath) {
            cellIdentifier = CellIdentifiers.AddCityCell.rawValue
            rowTitle = NSLocalizedString("ADD_CITY_CELL_TITLE", comment: "")
        }
        else {
            cellIdentifier = CellIdentifiers.SimpleCityCell.rawValue
            let city = userDefaults!.favouriteLocations[indexPath.row - 1]
            rowTitle = city.displayableName
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        cell.textLabel?.text = rowTitle
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return !isAddCityIndexPath(indexPath)
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return isAddCityIndexPath(indexPath) ? .None : .Delete
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
                let newIndexPath = NSIndexPath(forRow: userDefaults.favouriteLocations.count, inSection: 0)
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Automatic)
            }
        }
        navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - Other
    
    func finish() {
        delegate?.settingsViewControllerDidFinish(self)
    }
    
    func isAddCityIndexPath(indexPath: NSIndexPath) -> Bool {
        return indexPath.row == 0
    }
    
}

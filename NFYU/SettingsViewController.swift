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

class SettingsViewController: BaseTableViewController, CitySearchViewControllerDelegate {
    
    enum Segues: String {
        case AddCitySegue = "AddCitySegue"
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "finish")
        navigationItem.leftBarButtonItem = editButtonItem()
        title = NSLocalizedString("SETTINGS_TITLE", comment: "")
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + (userDefaults?.favouriteCities.count ?? 0)
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
            let city = userDefaults!.favouriteCities[indexPath.row - 1]
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
            var newCities = userDefaults.favouriteCities
            newCities.removeAtIndex(indexPath.row - 1)
            userDefaults.favouriteCities = newCities
        }
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if isAddCityIndexPath(indexPath) {
            performSegueWithIdentifier(Segues.AddCitySegue.rawValue, sender: indexPath)
        }
    }
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Segues.AddCitySegue.rawValue {
            let citySearchViewController = segue.destinationViewController as? CitySearchViewController
            citySearchViewController?.delegate = self
        }
    }
    
    // MARK: - CitySearchViewControllerDelegate
    
    func citySearchViewController(viewController: CitySearchViewController, didFinishWithCity city: City?) {
        dismissViewControllerAnimated(true, completion: nil)
        if let city = city {
            if let userDefaults = userDefaults {
                var newCities = userDefaults.favouriteCities
                newCities.append(city)
                userDefaults.favouriteCities = newCities
                let newIndexPath = NSIndexPath(forRow: userDefaults.favouriteCities.count, inSection: 0)
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Automatic)
            }
        }
    }
    
    // MARK: - Other
    
    func finish() {
        delegate?.settingsViewControllerDidFinish(self)
    }
    
    func isAddCityIndexPath(indexPath: NSIndexPath) -> Bool {
        return indexPath.row == 0
    }
    
}

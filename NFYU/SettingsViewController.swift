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

class SettingsViewController: UITableViewController {
    
    enum CellIdentifiers: String {
        case AddCityCell = "AddCityCell"
        case SimpleCityCell = "SimpleCityCell"
    }
    
    var delegate: SettingsViewControllerDelegate?
    var userDefaults: UserDefaults?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("SETTINGS_TITLE", comment: "")
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + (userDefaults?.favouriteCities.count ?? 0)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier: String
        let rowTitle: String
        if indexPath.row > 0 {
            cellIdentifier = CellIdentifiers.SimpleCityCell.rawValue
            let city = userDefaults!.favouriteCities[indexPath.row - 1]
            rowTitle = city.displayableName
        }
        else {
            cellIdentifier = CellIdentifiers.AddCityCell.rawValue
            rowTitle = NSLocalizedString("ADD_CITY_CELL_TITLE", comment: "")
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        cell.textLabel?.text = rowTitle
        return cell
    }
    
}

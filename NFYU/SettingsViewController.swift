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
    
    var delegate: SettingsViewControllerDelegate?

}

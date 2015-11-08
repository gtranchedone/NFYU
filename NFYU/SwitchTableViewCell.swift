//
//  SwitchTableViewCell.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 08/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import UIKit

protocol SwitchTableViewCellDelegate {
    
    func switchCellDidChangeSwitchValue(cell: SwitchTableViewCell)
    
}

class SwitchTableViewCell: UITableViewCell {

    var delegate: SwitchTableViewCellDelegate?
    var switchControl: UISwitch! {
        get {
            return self.accessoryView as! UISwitch
        }
    }
    override var accessoryView: UIView? {
        didSet {
            if let accessory = accessoryView as? UISwitch {
                accessory.addTarget(self, action: "switchValueChanged", forControlEvents: .ValueChanged)
            }
        }
    }
    
    func switchValueChanged() {
        delegate?.switchCellDidChangeSwitchValue(self)
    }
    
}

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
    @IBOutlet var switchControl: UISwitch! {
        didSet {
            switchControl.addTarget(self, action: "switchValueChanged", forControlEvents: .ValueChanged)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel!.backgroundColor = .clearColor()
    }
    
    func switchValueChanged() {
        delegate?.switchCellDidChangeSwitchValue(self)
    }
    
}

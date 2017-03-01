//
//  SwitchTableViewCell.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 08/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import UIKit

protocol SwitchTableViewCellDelegate {
    
    func switchCellDidChangeSwitchValue(_ cell: SwitchTableViewCell)
    
}

class SwitchTableViewCell: UITableViewCell {

    var delegate: SwitchTableViewCellDelegate?
    @IBOutlet var switchControl: UISwitch! {
        didSet {
            switchControl.addTarget(self, action: #selector(SwitchTableViewCell.switchValueChanged), for: .valueChanged)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel!.backgroundColor = .clear
    }
    
    func switchValueChanged() {
        delegate?.switchCellDidChangeSwitchValue(self)
    }
    
}

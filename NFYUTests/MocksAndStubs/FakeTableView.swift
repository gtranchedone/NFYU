//
//  FakeTableView.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 04/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import UIKit

class FakeTableView: UITableView {
    
    private(set) var didReloadData = false
    private(set) var insertedIndexPaths: [NSIndexPath] = []
    private(set) var deletedIndexPaths: [NSIndexPath] = []
    
    override func reloadData() {
        didReloadData = true
    }
    
    override func insertRowsAtIndexPaths(indexPaths: [NSIndexPath], withRowAnimation animation: UITableViewRowAnimation) {
        insertedIndexPaths = indexPaths
    }
    
    override func deleteRowsAtIndexPaths(indexPaths: [NSIndexPath], withRowAnimation animation: UITableViewRowAnimation) {
        deletedIndexPaths = indexPaths
    }
    
}

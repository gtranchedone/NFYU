//
//  FakeTableView.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 04/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import UIKit

class FakeTableView: UITableView {
    
    fileprivate(set) var didReloadData = false
    fileprivate(set) var insertedIndexPaths: [IndexPath] = []
    fileprivate(set) var deletedIndexPaths: [IndexPath] = []
    
    override func reloadData() {
        didReloadData = true
    }
    
    override func insertRows(at indexPaths: [IndexPath], with animation: UITableViewRowAnimation) {
        insertedIndexPaths = indexPaths
    }
    
    override func deleteRows(at indexPaths: [IndexPath], with animation: UITableViewRowAnimation) {
        deletedIndexPaths = indexPaths
    }
    
}

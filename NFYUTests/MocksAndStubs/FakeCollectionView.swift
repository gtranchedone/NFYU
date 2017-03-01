//
//  FakeCollectionView.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 04/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import UIKit

class FakeCollectionView: UICollectionView {
    
    fileprivate(set) var didReloadData = false
    fileprivate(set) var reloadedIndexPaths: [IndexPath]?
    
    var stubNumberOfSections = 0
    var stubNumberOfRows = 0
    
    convenience init() {
        self.init(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    override var numberOfSections : Int {
        return stubNumberOfSections
    }
    
    override func numberOfItems(inSection section: Int) -> Int {
        return stubNumberOfRows
    }
    
    override func reloadData() {
        didReloadData = true
    }
    
    override func reloadItems(at indexPaths: [IndexPath]) {
        reloadedIndexPaths = indexPaths
    }
    
}

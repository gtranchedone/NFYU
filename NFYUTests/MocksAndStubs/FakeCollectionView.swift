//
//  FakeCollectionView.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 04/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import UIKit

class FakeCollectionView: UICollectionView {
    
    private(set) var didReloadData = false
    private(set) var reloadedIndexPaths: [NSIndexPath]?
    
    convenience init() {
        self.init(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    override func reloadData() {
        didReloadData = true
    }
    
    override func reloadItemsAtIndexPaths(indexPaths: [NSIndexPath]) {
        reloadedIndexPaths = indexPaths
    }
    
}

//
//  CollectionViewDataSource.swift
//  Music Player
//
//  Created by Даниил on 17.09.2018.
//  Copyright © 2018 polat. All rights reserved.
//

import UIKit

class SectionedCollectionViewDataSource: NSObject, UICollectionViewDataSource {
    
    private let dataSources: [UICollectionViewDataSource]
    
    init(dataSources: [UICollectionViewDataSource]) {
        self.dataSources = dataSources
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSources.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let dataSource = dataSources[section]
        
        return dataSource.collectionView(collectionView, numberOfItemsInSection: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let dataSource = dataSources[indexPath.section]
        let indexPath = IndexPath(row: indexPath.row, section: 0)
    
        return dataSource.collectionView(collectionView, cellForItemAt: indexPath)
    }
}

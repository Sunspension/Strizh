//
//  GenericCollectionViewDataSource.swift
//  WorkPilots
//
//  Created by developer on 1/4/16.
//  Copyright © 2016 developer. All rights reserved.
//

import UIKit

class GenericCollectionViewDataSource<CollectionViewCell: UICollectionViewCell, CollectionItem: Any> : NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var sections: [GenericTableSection<CollectionItem>] = []
    
    var bindig: (CollectionViewCell, GenericTableSectionItem<CollectionItem>) -> Void
    
    var cellClass: AnyClass
    
    subscript(index: Int) -> GenericTableSection<CollectionItem> {
        
        get {
            
            return sections[index]
        }
        
        set {
            
            sections.insert(newValue, at: index)
        }
    }
    
    init(cellClass: AnyClass,
         binding: @escaping (_ cell: CollectionViewCell, _ item: GenericTableSectionItem<CollectionItem>) -> Void) {
        
        self.bindig = binding
        self.cellClass = cellClass
        
        super.init()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return self.sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.sections[section].items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let item = self.sections[indexPath.section].items[indexPath.row]
        item.indexPath = indexPath
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: cellClass),
                                                      for: indexPath) as! CollectionViewCell
        
        self.bindig(cell, item)
        
        return cell
    }
    
    func item(by: IndexPath) -> GenericTableSectionItem<CollectionItem> {
        
        return sections[by.section].items[by.row]
    }
}

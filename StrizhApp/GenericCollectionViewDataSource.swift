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
    
    var onDidSelectRowAtIndexPath: ((_ collectionView: UICollectionView, _ indexPath: IndexPath, _ item: GenericTableSectionItem<CollectionItem>) -> Void)?
    
    var onDidScrollToCellIndexPath: ((_ collectionView: UICollectionView, _ indexPath: IndexPath) -> Void)?
    
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.onDidSelectRowAtIndexPath?(collectionView, indexPath, self.item(by: indexPath))
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let rect = CGRect(origin: scrollView.contentOffset, size: scrollView.bounds.size)
        let point = CGPoint(x: rect.midX , y: rect.midY)
        
        let collectionView = scrollView as! UICollectionView
        
        if let indexPath = collectionView.indexPathForItem(at: point) {
            
            self.onDidScrollToCellIndexPath?(collectionView, indexPath)
        }
    }
    
    func item(by: IndexPath) -> GenericTableSectionItem<CollectionItem> {
        
        return sections[by.section].items[by.row]
    }
}

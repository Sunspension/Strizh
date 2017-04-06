//
//  CollectionViewDataSource.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 02/04/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit

class CollectionViewDataSource: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var sections: [CollectionSection] = []
    
    subscript(index: Int) -> CollectionSection {
        
        get {
            
            return sections[index]
        }
        
        set {
            
            sections.insert(newValue, at: index)
        }
    }
    
    
    func item(by: IndexPath) -> CollectionSectionItem {
        
        return sections[by.section].items[by.row]
    }
    
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return self.sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.sections[section].items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let item = self.sections[indexPath.section].items[indexPath.row]
        item.indexPath = indexPath
        
        if let cellClass = item.cellClass {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: cellClass),
                                                          for: indexPath)
            item.bindingAction?(cell, item)
            return cell
        }
        
        return UICollectionViewCell()
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        
//        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
//        let width = collectionView.bounds.width - flowLayout.sectionInset.left - flowLayout.sectionInset.right
//        return CGSize(width: width, height: 10)
//    }
}

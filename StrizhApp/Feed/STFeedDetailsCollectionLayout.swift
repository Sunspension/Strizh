//
//  STFeedDetailsCollectionLayout.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 12/02/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit

class STFeedDetailsCollectionLayout: UICollectionViewFlowLayout {

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        let attributes = super.layoutAttributesForItem(at: indexPath)?.copy() as? UICollectionViewLayoutAttributes
        
        guard let collectionView = collectionView else {
            
            return attributes
        }
        
        attributes?.bounds.size.width = collectionView.bounds.width - sectionInset.left - sectionInset.right
        return attributes
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        let allAttributes = super.layoutAttributesForElements(in: rect)
        
        return allAttributes?.flatMap { attributes in
            
            switch attributes.representedElementCategory {
                
            case .cell:
                return layoutAttributesForItem(at: attributes.indexPath)
                
            default:
                return attributes
            
            }
        }
    }
}

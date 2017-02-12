//
//  STPostDetailsPhotoCell.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 12/02/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit

class STPostDetailsPhotoCell: UICollectionViewCell {

    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet weak var busy: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        
        layoutAttributes.bounds.size.height = systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        return layoutAttributes
    }
    
    override func prepareForReuse() {
        
        image.image = nil
    }
}

//
//  STDialogMyCell.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 02/04/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit

class STDialogMyCell: UICollectionViewCell {
    
    @IBOutlet weak var bubbleImage: UIImageView!
    
    @IBOutlet weak var text: UILabel!
    
    @IBOutlet weak var time: UILabel!
    
    @IBOutlet weak var userImage: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        bubbleImage.tintColor = UIColor(red: 71 / 255.0, green: 122 / 255.0, blue: 251 / 255.0, alpha: 1)
    }
    
    override func prepareForReuse() {
        
//        userImage.setImage(UIImage(), for: .normal)
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        
        let height = systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        layoutAttributes.bounds.size.height = height
        return layoutAttributes
    }
}

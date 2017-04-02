//
//  STDialogOtherCell.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 02/04/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit

class STDialogOtherCell: UICollectionViewCell {
    
    @IBOutlet weak var bubbleImage: UIImageView!
    
    @IBOutlet weak var text: UILabel!
    
    @IBOutlet weak var time: UILabel!
    
    @IBOutlet weak var userImage: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        bubbleImage.tintColor = UIColor(red: 234 / 255.0, green: 234 / 255.0, blue: 234 / 255.0, alpha: 1)
        text.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.75)
        time.textColor = UIColor(red: 167 / 255.0, green: 167 / 255.0, blue: 167 / 255.0, alpha: 0.8)
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

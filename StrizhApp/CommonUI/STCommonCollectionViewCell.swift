//
//  STPostDetailsCollectionViewCell.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 12/02/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit

class STCommonCollectionViewCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var leftMargin: NSLayoutConstraint!
    
    @IBOutlet weak var rightMargin: NSLayoutConstraint!
    
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    
    var itemSize: CGSize {
        
        get {
            
            return (self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        }
        
        set {
            
            (self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize = newValue
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

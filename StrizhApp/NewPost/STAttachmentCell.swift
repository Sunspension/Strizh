//
//  STAttachmentCell.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 10/03/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit

class STAttachmentCell: UITableViewCell {

    @IBOutlet weak var icon: UIImageView!
    
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var subtitle: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var bottomIconMargin: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        (self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize = CGSize(width: 92, height: 72)
        self.collectionView.register(nib: STAttachmentPhotoCell.self)
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        
        collectionViewHeight.constant = 0
        bottomIconMargin.constant = 0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func expandCellIfNeeded() {
        
        if (collectionView.numberOfItems(inSection: 0) > 0) {
            
            collectionViewHeight.constant = 68
            bottomIconMargin.constant = 8
        }
        else {
            
            collectionViewHeight.constant = 0
            bottomIconMargin.constant = 0
        }
    }
}

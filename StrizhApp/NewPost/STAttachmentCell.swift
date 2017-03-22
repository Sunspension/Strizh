//
//  STAttachmentCell.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 10/03/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import ReactiveKit

class STAttachmentCell: UITableViewCell {

    @IBOutlet weak var icon: UIImageView!
    
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var subtitle: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var bottomIconMargin: NSLayoutConstraint!
    
    @IBOutlet weak var actionButton: UIButton!
    
    var bag = DisposeBag()
    
    deinit {
        
        bag.dispose()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        (self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize = CGSize(width: 92, height: 72)
        self.collectionView.register(nib: STAttachmentPhotoCell.self)
        
        self.actionButton.layer.borderWidth = 1
        self.actionButton.layer.borderColor = UIColor.stLightishBlue.cgColor
        self.actionButton.layer.cornerRadius = 5
        self.actionButton.clipsToBounds = true
        
        self.actionButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        
        collectionViewHeight.constant = 0
        bottomIconMargin.constant = 0
        bag.dispose()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func exapandCell() {
        
        collectionViewHeight.constant = 68
        bottomIconMargin.constant = 8
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

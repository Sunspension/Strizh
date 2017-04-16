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
    
    @IBOutlet weak var actionButton: UIButton!
    
    @IBOutlet weak var containerHeight: NSLayoutConstraint!
    
    var disposeBag = DisposeBag()
    
    deinit {
        
        disposeBag.dispose()
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
        
//        self.collectionViewHeight.constant = 0
        self.containerHeight.constant = 60
        disposeBag.dispose()
    }
    
    func expandCell() {
        
        if self.containerHeight.constant == 135 {
            
            return
        }
        
//        self.collectionViewHeight.constant = 68
        self.containerHeight.constant = 135
    }
    
    func collapsCell() {
        
        if self.containerHeight.constant == 60 {
            
            return
        }
        
//        self.collectionViewHeight.constant = 0
        self.containerHeight.constant = 60
    }    
}

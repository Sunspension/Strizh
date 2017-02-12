//
//  STPostDetailsCollectionViewCell.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 12/02/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit

class STPostDetailsCollectionViewCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    
    private let flowLayout = STFeedDetailsCollectionLayout()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.flowLayout.estimatedItemSize = flowLayout.itemSize
        
        self.collectionView.register(cell: STPostDetailsPhotoCell.self)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

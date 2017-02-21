//
//  STEditProfileHeaderCell.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 16/02/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import ReactiveKit

class STEditProfileHeaderCell: UITableViewCell {

    @IBOutlet weak var userImage: UIButton!
    
    @IBOutlet weak var deleteAvatar: UIButton!

    var bag = DisposeBag()
    
    deinit {
        
        bag.dispose()
    }
    
    override func prepareForReuse() {
        
        bag.dispose()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        deleteAvatar.setTitleColor(UIColor.stBrick, for: .normal)
        userImage.imageView?.contentMode = .scaleAspectFill
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

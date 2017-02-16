//
//  STEditProfileHeaderCell.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 16/02/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit

class STEditProfileHeaderCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var deleteAvater: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        deleteAvater.setTitleColor(UIColor.stBrick, for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

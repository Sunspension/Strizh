//
//  STLoginAvatarTableViewCell.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 28/01/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit

class STLoginAvatarTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.avatarButton.imageView?.contentMode = .scaleAspectFill
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

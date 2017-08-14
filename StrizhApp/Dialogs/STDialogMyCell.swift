//
//  STDialogMyCell.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 06/04/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit

class STDialogMyCell: UITableViewCell {

    @IBOutlet weak var messageText: UILabel!
    
    @IBOutlet weak var time: UILabel!
    
    @IBOutlet weak var userImage: UIButton!

    @IBOutlet weak var bubbleImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.bubbleImage.tintColor = UIColor(red: 71 / 255.0, green: 122 / 255.0, blue: 251 / 255.0, alpha: 1)
        self.selectionStyle = .none
        self.userImage.imageView?.image = nil
    }

    override func prepareForReuse() {
        
        self.userImage.imageView?.image = nil
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

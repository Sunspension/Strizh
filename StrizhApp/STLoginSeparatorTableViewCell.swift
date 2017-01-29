//
//  STLoginSeparatorTableViewCell.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 28/01/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit

class STLoginSeparatorTableViewCell: UITableViewCell {

    @IBOutlet weak var separator: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        separator.backgroundColor = UIColor(white: 1, alpha: 0.3)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

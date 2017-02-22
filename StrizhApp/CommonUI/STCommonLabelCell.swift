//
//  STCommonLabelCell.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 20/02/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit

class STCommonLabelCell: UITableViewCell {

    @IBOutlet weak var value: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

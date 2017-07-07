//
//  STClickableLableCell.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 07/07/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit

class STClickableLabelCell: UITableViewCell {

    @IBOutlet weak var clickableLabel: ClickableLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.clickableLabel.text = ""
        self.clickableLabel.isUserInteractionEnabled = true
    }
    
    override func prepareForReuse() {
        
        self.clickableLabel.text = ""
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

//
//  STFeedFilterTableViewCell.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 09/02/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit

class STFeedFilterTableViewCell: UITableViewCell {

    @IBOutlet weak var icon: UIImageView!
    
    @IBOutlet weak var title: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        self.tintColor = selected ? UIColor.stBrightBlue : UIColor.lightGray
    }
    
}

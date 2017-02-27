//
//  STPersonalPostDetailsMainInfoCell.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 27/02/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit

class STPersonalPostDetailsMainInfoCell: UITableViewCell {

    @IBOutlet weak var postType: UIButton!
    
    @IBOutlet weak var createdTitle: UILabel!
    
    @IBOutlet weak var createdAt: UILabel!
    
    @IBOutlet weak var openedDialogs: UILabel!
    
    @IBOutlet weak var dialogsCount: UILabel!
    
    @IBOutlet weak var postTitle: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

//
//  STLoginTableViewCell.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 23/01/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import SHSPhoneComponent

class STLoginTableViewCell: UITableViewCell {
        
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var value: SHSPhoneTextField!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        value.tintColor = UIColor.white
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

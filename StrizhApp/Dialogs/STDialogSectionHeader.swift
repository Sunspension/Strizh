//
//  STDialogSectionHeader.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 09/04/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit

class STDialogSectionHeader: UITableViewHeaderFooterView {
    
    @IBOutlet weak var dateLabel: UILabel!

    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        self.backgroundView = UIView()
        self.backgroundView?.backgroundColor = UIColor.white
    }
    
    override func prepareForReuse() {
        
        dateLabel.text = ""
    }
}

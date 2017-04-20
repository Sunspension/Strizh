//
//  STProfileFooterCell.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 14/02/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit

class STProfileFooterCell: UITableViewHeaderFooterView {

    @IBOutlet weak var label: UILabel!
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        if backgroundView == nil {
            
            backgroundView = UIView()
        }
        
        self.backgroundView!.backgroundColor = UIColor.clear
    }
}

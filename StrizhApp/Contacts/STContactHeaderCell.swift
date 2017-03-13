//
//  STContactHeaderCell.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 26/02/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit

class STContactHeaderCell: UITableViewHeaderFooterView {

    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var topSpace: NSLayoutConstraint!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        if backgroundView == nil {
            
            backgroundView = UIView()
        }
        
        self.backgroundView!.backgroundColor = UIColor.stLightBlueGrey
        title.textColor = UIColor.black
    }
}

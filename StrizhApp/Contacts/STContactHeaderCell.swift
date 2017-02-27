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
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        self.contentView.backgroundColor = UIColor.stLightBlueGrey
        title.textColor = UIColor.black
    }
}

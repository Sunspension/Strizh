//
//  STFeedFilterSwitchTableViewCell.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 09/02/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit

class STFeedFilterSwitchTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var toggle: UISwitch!
    
    @IBOutlet weak var spiner: UIActivityIndicatorView!
    
    var onTogglePressed: ((_ isOn: Bool) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
        toggle.onTintColor = UIColor.stBrightBlue
        toggle.addTarget(self, action: #selector(self.togglePressed), for: .valueChanged)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    @objc fileprivate func togglePressed() {
        
        onTogglePressed?(toggle.isOn)
    }
}

//
//  STTextFieldCell.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 02/03/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import ReactiveKit

class STTextFieldCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var value: UITextField!
    
    var bag = DisposeBag()
    
    
    deinit {
        
        bag.dispose()
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        title.text = ""
        value.placeholder = ""
        value.text = ""
        
        selectionStyle = .none
    }

    override func prepareForReuse() {
        
        title.text = ""
        value.placeholder = ""
        value.text = ""
        value.keyboardType = .default
        
        bag.dispose()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

//
//  STTextViewCell.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 13/03/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import ReactiveKit

class STTextViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var value: UITextView!
    
    var bag = DisposeBag()
    
    
    deinit {
        
        bag.dispose()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        title.text = ""
        value.text = ""
        value.textContainerInset = UIEdgeInsets(top: 8, left: -4, bottom: 8, right: 0)
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

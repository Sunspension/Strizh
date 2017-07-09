//
//  STEditProfileTextCell.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 16/02/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import ReactiveKit

class STEditProfileTextCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var value: UITextField!
    
    var disposeBag = DisposeBag()
    
    
    override func prepareForReuse() {
        
        disposeBag = DisposeBag()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        title.text = ""
        value.text = ""
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

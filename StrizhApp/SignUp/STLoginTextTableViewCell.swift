//
//  STLoginTextTableViewCell.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 28/01/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import ReactiveKit

class STLoginTextTableViewCell: UITableViewCell {

    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var value: UITextField!
    
    var disposeBag = DisposeBag()
    
    
    override func prepareForReuse() {
        
        self.disposeBag = DisposeBag()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        value.tintColor = UIColor.white
        title.text = ""
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

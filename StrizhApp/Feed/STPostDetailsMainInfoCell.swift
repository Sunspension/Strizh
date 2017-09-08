//
//  STPostDetailsMainInfoCell.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 10/02/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import ReactiveKit

class STPostDetailsMainInfoCell: UITableViewCell {

    @IBOutlet weak var userIcon: UIImageView!

    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var postTime: UILabel!
    
    @IBOutlet weak var dialogsCount: UIButton!
    
    @IBOutlet weak var postTitle: UILabel!
    
    var disposeBag = DisposeBag()
    
    
    override func prepareForReuse() {
        
        disposeBag = DisposeBag()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        dialogsCount.setTitleColor(UIColor.stSteelGrey, for: .normal)
        dialogsCount.layer.backgroundColor = UIColor.stPaleGrey.cgColor
        dialogsCount.layer.cornerRadius = 5
        dialogsCount.layer.masksToBounds = true
    }
}

//
//  STDialogOtherCell.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 06/04/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import ReactiveKit

class STDialogOtherCell: UITableViewCell {

    @IBOutlet weak var messageText: UILabel!
    
    @IBOutlet weak var time: UILabel!
    
    @IBOutlet weak var userImage: UIButton!
    
    @IBOutlet weak var bubbleImage: UIImageView!
    
    var disposeBag = DisposeBag()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.bubbleImage.tintColor = UIColor(red: 234 / 255.0, green: 234 / 255.0, blue: 234 / 255.0, alpha: 1)
        self.messageText.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.75)
        self.time.textColor = UIColor(red: 167 / 255.0, green: 167 / 255.0, blue: 167 / 255.0, alpha: 0.8)
        self.selectionStyle = .none
        self.userImage.imageView?.image = nil
    }

    override func prepareForReuse() {
        
        disposeBag = DisposeBag()
        self.userImage.imageView?.image = nil
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

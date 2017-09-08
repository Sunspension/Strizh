//
//  STLoginAvatarTableViewCell.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 28/01/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import ReactiveKit

class STLoginAvatarTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarButton: UIButton!

    var disposeBag = DisposeBag()
    
    
    override func prepareForReuse() {
        
        disposeBag = DisposeBag()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.avatarButton.imageView?.contentMode = .scaleAspectFill
    }
}

//
//  STEditProfileHeaderCell.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 16/02/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import ReactiveKit

class STEditProfileHeaderCell: UITableViewCell {

    @IBOutlet weak var userImage: UIButton!
    
    @IBOutlet weak var deleteAvatar: UIButton!

    var disposeBag = DisposeBag()
    
    deinit {
        
        disposeBag.dispose()
    }
    
    override func prepareForReuse() {
        
        disposeBag.dispose()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        deleteAvatar.setTitleColor(UIColor.stBrick, for: .normal)
        userImage.imageView?.contentMode = .scaleAspectFill
        
        let transition = CATransition()
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        transition.type = kCATransitionFade
        transition.duration = 0.2
        self.userImage.imageView?.layer.add(transition, forKey: "userImage")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

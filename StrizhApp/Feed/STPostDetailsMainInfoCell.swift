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
    
    @IBOutlet weak var postType: UIButton!
    
    @IBOutlet weak var favorite: UIButton!
    
    @IBOutlet weak var postTitle: UILabel!
    
    var bag = DisposeBag()
    

    deinit {
        
        bag.dispose()
    }
    
    override func prepareForReuse() {
        
        bag.dispose()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        favorite.setImage(UIImage(named: "icon-star"), for: .normal)
        favorite.setImage(UIImage(named: "icon-star-selected"), for: .selected)
        
        postType.setImage(UIImage(named: "icon-offer"), for: .normal)
        postType.setImage(UIImage(named: "icon-search"), for: .selected)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

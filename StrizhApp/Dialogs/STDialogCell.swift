//
//  STDialogCell.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 21/03/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit

class STDialogCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var inOutIcon: CircledButton!
    
    @IBOutlet weak var topicTitle: UILabel!
    
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var message: UILabel!
    
    @IBOutlet weak var time: UILabel!
    
    @IBOutlet weak var newMessageCounter: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        newMessageCounter.layer.cornerRadius = newMessageCounter.layer.bounds.size.height / 2
        newMessageCounter.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

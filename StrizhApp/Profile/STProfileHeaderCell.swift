//
//  STProfileHeaderCell.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 13/02/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit

class STProfileHeaderCell: UITableViewCell {

    
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var edit: UIButton!
    
    @IBOutlet weak var settings: UIButton!
    
    @IBOutlet weak var userName: UILabel!
    
    
    func setImageWithTransition(image: UIImage?) {
        
        UIView.transition(with: userImage, duration: 0.3, options: .transitionCrossDissolve, animations: { 
            
           self.userImage?.image = image
            
        }, completion: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

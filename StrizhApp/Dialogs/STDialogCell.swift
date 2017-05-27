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
        
        self.selectionStyle = .none
        
        if self.backgroundView == nil {
            
            self.backgroundView = UIView()
        }
        
        inOutIcon.setImage(UIImage(named: "icon-arrow-in"), for: .normal)
        inOutIcon.setImage(UIImage(named: "icon-arrow-out"), for: .selected)
        
        self.clear()
        newMessageCounter.layer.cornerRadius = newMessageCounter.layer.bounds.size.height / 2
        newMessageCounter.clipsToBounds = true
    }
    
    override func prepareForReuse() {
        
        self.clear()
        userImage.image = UIImage(named: "avatar")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    fileprivate func clear() {
        
        message.attributedText = nil
        message.text = ""
        topicTitle.text = ""
    }
}

//
//  STPersonalPostCell.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 14/02/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit

class STPersonalPostCell: UITableViewCell {

    @IBOutlet weak var container: UIView!
    
    @IBOutlet weak var postType: UIButton!
    
    @IBOutlet weak var createdTitle: UILabel!
    
    @IBOutlet weak var createdAt: UILabel!
    
    @IBOutlet weak var openDialogsTitle: UILabel!
    
    @IBOutlet weak var dialogsCount: UILabel!
    
    @IBOutlet weak var more: UIButton!
    
    @IBOutlet weak var postTitle: UILabel!
    
    @IBOutlet weak var postDetails: UILabel!
    
    @IBOutlet weak var duration: UIButton!
    
    @IBOutlet weak var header: UIView!
    
    @IBOutlet weak var separator: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        container.layer.cornerRadius = 5
        container.layer.masksToBounds = true
        container.layer.shouldRasterize = true
        container.layer.rasterizationScale = UIScreen.main.scale
        container.layer.contentsScale = UIScreen.main.scale
        
        separator.layer.shouldRasterize = true
        
        header.layer.shouldRasterize = true
        header.layer.rasterizationScale = UIScreen.main.scale
        header.layer.contentsScale = UIScreen.main.scale
        
        postType.setImage(UIImage(named: "icon-offer"), for: .normal)
        postType.setImage(UIImage(named: "icon-search"), for: .selected)
        
        more.tintColor = UIColor.stGreyblue
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

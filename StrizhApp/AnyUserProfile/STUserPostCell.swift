//
//  STUserPostCell.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 09/08/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit

class STUserPostCell: UITableViewCell {
    
    @IBOutlet weak var container: UIView!
    
    @IBOutlet weak var userIcon: UIButton!
    
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var postTime: UILabel!
    
    @IBOutlet weak var dialogsCount: UIButton!
    
    @IBOutlet weak var iconFavorite: UIButton!
    
    @IBOutlet weak var postTitle: UILabel!
    
    @IBOutlet weak var postDetails: UILabel!
    
    @IBOutlet weak var durationDate: UIButton!
    
    @IBOutlet weak var separator: UIView!
    
    @IBOutlet weak var header: UIView!
    
    var onFavoriteButtonTap: (() -> Void)?
    
    var onUserIconButtonTap: (() -> Void)?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        container.layer.cornerRadius = 5
        container.layer.masksToBounds = true
        
        separator.layer.shouldRasterize = true
        
        header.layer.shouldRasterize = true
        header.layer.rasterizationScale = UIScreen.main.scale
        header.layer.contentsScale = UIScreen.main.scale
        
        userName.text = ""
        
        iconFavorite.setImage(UIImage(named: "icon-star"), for: .normal)
        iconFavorite.setImage(UIImage(named: "icon-star-selected"), for: .selected)
        iconFavorite.tintColor = UIColor.lightGray
        
        dialogsCount.setTitleColor(UIColor.stSteelGrey, for: .normal)
        dialogsCount.layer.backgroundColor = UIColor.stPaleGrey.cgColor
        dialogsCount.layer.cornerRadius = 5
        dialogsCount.layer.masksToBounds = true
        
        iconFavorite.addTarget(self, action: #selector(self.tapOnFavorite), for: .touchUpInside)
        userIcon.addTarget(self, action: #selector(self.tapOnUserIcon), for: .touchUpInside)
    }

    override func prepareForReuse() {
        
        userIcon.imageView?.image = nil
    }
    
    @objc func tapOnFavorite() {
        
        self.onFavoriteButtonTap?()
    }
    
    @objc func tapOnUserIcon() {
        
        self.onUserIconButtonTap?()
    }
}

//
//  STPostTableViewCell.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 05/02/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit

class STPostTableViewCell: UITableViewCell {

    
    @IBOutlet weak var container: UIView!
    
    @IBOutlet weak var userIcon: UIButton!
    
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var postTime: UILabel!
    
    @IBOutlet weak var postType: UIButton!
    
    @IBOutlet weak var iconFavorite: UIButton!
    
    @IBOutlet weak var postTitle: UILabel!
    
    @IBOutlet weak var postDetails: UILabel!
    
    @IBOutlet weak var durationDate: UIButton!
    
    @IBOutlet weak var images: UIButton!
    
    @IBOutlet weak var documents: UIButton!
    
    @IBOutlet weak var locations: UIButton!
    
    @IBOutlet weak var separator: UIView!
    
    @IBOutlet weak var header: UIView!
    
    var onFavoriteButtonTap: (() -> Void)?
    
    var onUserIconButtonTap: (() -> Void)?

    
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
        
        userName.text = ""
        
        iconFavorite.setImage(UIImage(named: "icon-star"), for: .normal)
        iconFavorite.setImage(UIImage(named: "icon-star-selected"), for: .selected)
        
        postType.setImage(UIImage(named: "icon-offer"), for: .normal)
        postType.setImage(UIImage(named: "icon-search"), for: .selected)
        
        let disabledColor = UIColor(red: 211 / 255.0, green: 211 / 255.0, blue: 211 / 255.0, alpha: 1)
        
        images.setTitleColor(disabledColor, for: .disabled)
        locations.setTitleColor(disabledColor, for: .disabled)
        documents.setTitleColor(disabledColor, for: .disabled)
        
        iconFavorite.addTarget(self, action: #selector(self.tapOnFavorite), for: .touchUpInside)
        
        userIcon.imageView?.contentMode = .scaleAspectFit
        userIcon.imageView?.image = nil
        
        userIcon.addTarget(self, action: #selector(self.tapOnUserIcon), for: .touchUpInside)
    }

    override func prepareForReuse() {
        
        userIcon.imageView?.image = nil
    }
    
    func tapOnFavorite() {
        
        self.onFavoriteButtonTap?()
    }
    
    func tapOnUserIcon() {
        
        self.onUserIconButtonTap?()
    }
}

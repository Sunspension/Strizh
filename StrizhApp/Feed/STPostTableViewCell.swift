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
    
    @IBOutlet weak var separator: UIView!
    
    @IBOutlet weak var header: UIView!
    
    var onFavoriteButtonTap: (() -> Void)?
    
    var onUserIconButtonTap: (() -> Void)?
    
    var isSearch: Bool {
        
        get {
            
            return postType.isSelected
        }
        
        set {
            
            postType.isSelected = newValue
            postType.layer.backgroundColor = newValue == true ?
                UIColor.stIris.cgColor : UIColor.stDarkMint.cgColor
        }
    }
    
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
        
        postType.setImage(UIImage(named: "ic-offer"), for: .normal)
        postType.setImage(UIImage(named: "ic-search"), for: .selected)
        
        postType.setTitle("post_page_button_offer_title".localized, for: .normal)
        postType.setTitle("post_page_button_search_title".localized, for: .selected)
        
        postType.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        postType.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 6)
        
        postType.layer.backgroundColor = UIColor.stDarkMint.cgColor
        postType.layer.cornerRadius = 5
        postType.layer.masksToBounds = true
        postType.imageView?.contentMode = .scaleAspectFit
        
        iconFavorite.addTarget(self, action: #selector(self.tapOnFavorite), for: .touchUpInside)
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

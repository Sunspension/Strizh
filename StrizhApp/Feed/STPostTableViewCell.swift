//
//  STPostTableViewCell.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 05/02/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import ReactiveKit

class STPostTableViewCell: UITableViewCell {

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
    
    var disposeBag = DisposeBag()
    
    
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
        
        dialogsCount.layer.backgroundColor = UIColor.stPaleGrey.cgColor
        dialogsCount.layer.cornerRadius = 5
        dialogsCount.layer.masksToBounds = true
        dialogsCount.setTitleColor(UIColor.stSteelGrey, for: .normal)
        
        iconFavorite.addTarget(self, action: #selector(self.tapOnFavorite), for: .touchUpInside)
        userIcon.addTarget(self, action: #selector(self.tapOnUserIcon), for: .touchUpInside)
    }

    override func prepareForReuse() {
        
        userIcon.imageView?.image = nil
        self.disposeBag = DisposeBag()
    }
    
    func tapOnFavorite() {
        
        self.onFavoriteButtonTap?()
    }
    
    func tapOnUserIcon() {
        
        self.onUserIconButtonTap?()
    }
}

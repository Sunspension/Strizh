//
//  STPersonalPostCell.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 14/02/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import ReactiveKit

class STPersonalPostCell: UITableViewCell {

    @IBOutlet weak var container: UIView!
    
    @IBOutlet weak var userIcon: UIButton!
    
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var createdAt: UILabel!
    
    @IBOutlet weak var more: UIButton!
    
    @IBOutlet weak var dialogsCount: UIButton!
    
    @IBOutlet weak var iconFavorite: UIButton!
    
    @IBOutlet weak var postTitle: UILabel!
    
    @IBOutlet weak var postDetails: UILabel!
    
    @IBOutlet weak var duration: UIButton!
    
    @IBOutlet weak var header: UIView!
    
    @IBOutlet weak var separator: UIView!
    
    var onFavoriteButtonTap: (() -> Void)?
    
    var disposeBag = DisposeBag()
    
    
    override func prepareForReuse() {
        
        disposeBag = DisposeBag()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        container.layer.cornerRadius = 5
        container.layer.masksToBounds = true
        container.layer.rasterizationScale = UIScreen.main.scale
        container.layer.contentsScale = UIScreen.main.scale
        
        separator.layer.shouldRasterize = true
        
        header.layer.shouldRasterize = true
        header.layer.rasterizationScale = UIScreen.main.scale
        header.layer.contentsScale = UIScreen.main.scale
        
        dialogsCount.setTitleColor(UIColor.stSteelGrey, for: .normal)
        dialogsCount.layer.backgroundColor = UIColor.stPaleGrey.cgColor
        dialogsCount.layer.cornerRadius = 5
        dialogsCount.layer.masksToBounds = true
        
        iconFavorite.setImage(UIImage(named: "icon-star"), for: .normal)
        iconFavorite.setImage(UIImage(named: "icon-star-selected"), for: .selected)
        iconFavorite.tintColor = UIColor.lightGray
        iconFavorite.addTarget(self, action: #selector(self.tapOnFavorite), for: .touchUpInside)
        
        more.tintColor = UIColor.lightGray
    }
    
    @objc func tapOnFavorite() {
        
        self.onFavoriteButtonTap?()
    }
}

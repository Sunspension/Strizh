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
    
    @IBOutlet weak var postTitle: UILabel!
    
    var disposeBag = DisposeBag()
    
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
    
    override func prepareForReuse() {
        
        disposeBag = DisposeBag()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        postType.setImage(UIImage(named: "icon-offer"), for: .normal)
        postType.setImage(UIImage(named: "icon-search"), for: .selected)
        
        postType.setTitle("post_page_button_offer_title".localized, for: .normal)
        postType.setTitle("post_page_button_search_title".localized, for: .selected)
        
        postType.layer.backgroundColor = UIColor.stDarkMint.cgColor
        postType.layer.cornerRadius = 5
        postType.layer.masksToBounds = true
        postType.imageView?.contentMode = .scaleAspectFit
    }
}

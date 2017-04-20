//
//  STPostButtonsCell.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 02/03/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import ReactiveKit

class STPostButtonsCell: UITableViewCell {

    
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var stackView: UIStackView!
  
    @IBOutlet weak var offer: UIButton!
    
    @IBOutlet weak var search: UIButton!
    
    var disposeBag = DisposeBag()
    
    
    deinit {
        
        disposeBag.dispose()
    }
    
    override func prepareForReuse() {
        
        disposeBag.dispose()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        offer.setTitle("post_page_button_offer_title".localized, for: .normal)
        offer.layer.cornerRadius = 5
        offer.layer.masksToBounds = true
        offer.layer.borderWidth = 1
        offer.layer.borderColor = UIColor.stDarkMint.cgColor
        
        offer.setTitleColor(UIColor.white, for: .selected)
        offer.setTitleColor(UIColor.stDarkMint, for: .normal)
        offer.tintColor = UIColor.white
        
        search.setTitle("post_page_button_search_title".localized, for: .normal)
        search.layer.cornerRadius = 5
        search.layer.masksToBounds = true
        search.layer.borderWidth = 1
        search.layer.borderColor = UIColor.stIris.cgColor
        
        search.setTitleColor(UIColor.white, for: .selected)
        search.setTitleColor(UIColor.stIris, for: .normal)
        search.tintColor = UIColor.white
        
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setType(type: Int) {
        
        if type == 1 {
            
            self.offerButtonSelected(true)
        }
        else if type == 2 {
            
            self.searchButtonSelected(true)
        }
    }
    
    func offerButtonSelected(_ selected: Bool) {
        
        self.offer.isSelected = selected
        self.offer.backgroundColor = selected ? UIColor.stDarkMint : UIColor.white
        self.offer.tintColor = selected ? UIColor.white : UIColor.stDarkMint
        
        self.search.isSelected = !selected
        self.search.backgroundColor = !selected ? UIColor.stIris : UIColor.white
        self.search.tintColor = !selected ? UIColor.white : UIColor.stIris
    }
    
    func searchButtonSelected(_ selected: Bool) {
        
        self.search.isSelected = selected
        self.search.backgroundColor = selected ? UIColor.stIris : UIColor.white
        self.search.tintColor = selected ? UIColor.white : UIColor.stIris
        
        self.offer.isSelected = !selected
        self.offer.backgroundColor = !selected ? UIColor.stDarkMint : UIColor.white
        self.offer.tintColor = !selected ? UIColor.white : UIColor.stDarkMint
    }
}

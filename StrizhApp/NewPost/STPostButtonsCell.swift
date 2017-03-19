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
    
    var bag = DisposeBag()
    
    
    deinit {
        
        bag.dispose()
    }
    
    override func prepareForReuse() {
        
        bag.dispose()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        offer.layer.cornerRadius = 5
        offer.layer.masksToBounds = true
        offer.layer.borderWidth = 1
        offer.layer.borderColor = UIColor.stDarkMint.cgColor
        
        offer.setTitleColor(UIColor.white, for: .selected)
        offer.setTitleColor(UIColor.stDarkMint, for: .normal)
        offer.tintColor = UIColor.white
        
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
            
            self.offerButtonSelected(selected: true)
        }
        else if type == 2 {
            
            self.searchButtonSelected(selected: true)
        }
    }
    
    func offerButtonSelected(selected: Bool) {
        
        self.offer.isSelected = selected
        self.offer.backgroundColor = selected ? UIColor.stDarkMint : UIColor.white
        self.offer.tintColor = selected ? UIColor.white : UIColor.stDarkMint
        
        self.search.isSelected = !selected
        self.search.backgroundColor = !selected ? UIColor.stIris : UIColor.white
        self.search.tintColor = !selected ? UIColor.white : UIColor.stIris
    }
    
    func searchButtonSelected(selected: Bool) {
        
        self.search.isSelected = selected
        self.search.backgroundColor = selected ? UIColor.stIris : UIColor.white
        self.search.tintColor = selected ? UIColor.white : UIColor.stIris
        
        self.offer.isSelected = !selected
        self.offer.backgroundColor = !selected ? UIColor.stDarkMint : UIColor.white
        self.offer.tintColor = !selected ? UIColor.white : UIColor.stDarkMint
    }
}

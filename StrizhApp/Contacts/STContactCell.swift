//
//  STContactCell.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 25/02/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import ReactiveKit

class STContactCell: UITableViewCell {

    @IBOutlet weak var contactImage: UIButton!
    
    @IBOutlet weak var contactName: UILabel!
    
    fileprivate var isDisable = false
    
    var disposeBag = DisposeBag()
    
    var disableSelection = false
    
    var isDisabledCell: Bool {
        
        get {
            
            return self.isDisable
        }
        
        set {
            
            self.isUserInteractionEnabled = !newValue
            self.contentView.alpha = newValue ? 0.4 : 1
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
        
        if self.backgroundView == nil {
            
            self.backgroundView = UIView()
        }
    }

    override func prepareForReuse() {
        
        disposeBag = DisposeBag()
        contactImage.imageView?.image = nil
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if disableSelection {
            
            return
        }
        
        self.tintColor = selected ? UIColor.stBrightBlue : UIColor.lightGray
        self.backgroundView?.backgroundColor = selected ? UIColor.stLightGreenGrey : UIColor.clear
    }
}

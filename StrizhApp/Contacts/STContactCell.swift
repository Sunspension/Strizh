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

    @IBOutlet weak var contactImage: CircledImageView!
    
    @IBOutlet weak var contactName: UILabel!
    
    @IBOutlet weak var addContact: UIButton!
    
    var disposeBag = DisposeBag()
    
    var disableSelection = false
    
    
    deinit {
        
        disposeBag.dispose()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
        
        if self.backgroundView == nil {
            
            self.backgroundView = UIView()
        }
        
        contactImage.image = nil;
    }

    override func prepareForReuse() {
        
        disposeBag = DisposeBag()
        contactImage.image = nil;
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

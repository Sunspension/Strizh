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

    @IBOutlet weak var contactImage: UIImageView!
    
    @IBOutlet weak var contactName: UILabel!
    
    @IBOutlet weak var addContact: UIButton!
    
    var disposeBag = DisposeBag()
    
    
    deinit {
        
        disposeBag.dispose()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
        
        if self.backgroundView == nil {
            
            self.backgroundView = UIView()
        }
    }

    override func prepareForReuse() {
        
        disposeBag.dispose()
        contactImage.image = UIImage(named: "avatar")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        self.tintColor = selected ? UIColor.stBrightBlue : UIColor.lightGray
        self.backgroundView?.backgroundColor = selected ? UIColor.stLightGreenGrey : UIColor.clear
    }
}

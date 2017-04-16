//
//  STDummyView.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 16/04/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit

class STDummyView: UIView {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var subTitle: UILabel!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        self.backgroundColor = UIColor.stLightBlueGrey
    }
}

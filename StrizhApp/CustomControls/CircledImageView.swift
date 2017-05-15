//
//  CircledImageView.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 15/05/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit

class CircledImageView: UIImageView {

    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        let radius = min(self.layer.bounds.size.width, self.layer.bounds.size.height) / 2
        self.layer.cornerRadius = radius
        self.clipsToBounds = true
    }
}

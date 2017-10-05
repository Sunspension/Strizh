//
//  ClikableLabel.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 07/07/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit

class ClickableLabel: UILabel {
    
    var clikableRanges = [NSRange]()
    
    var onTextClikAction: ((_ range: NSRange) -> Void)?
    
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        recognizerSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        recognizerSetup()
    }
    
    func recognizerSetup() {
    
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.recognizerHandler(_:)))
        self.addGestureRecognizer(tapRecognizer)
    }
    
    @objc func recognizerHandler(_ recognizer: UITapGestureRecognizer) {
        
        guard recognizer.state == .ended else {
            
            return
        }
        
        for range in self.clikableRanges {
            
            if recognizer.didTapAttributedText(in: self, inRange: range) {
                
                self.onTextClikAction?(range)
                break
            }
        }
    }
}

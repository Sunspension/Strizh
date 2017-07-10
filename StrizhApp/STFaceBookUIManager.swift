//
//  STFaceBookUIManager.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 08/07/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation
import AccountKit

class STFaceBookUIManager: NSObject, AKFUIManager {
    
    fileprivate let container = UIView.loadFromNib(view: STTermsCustomView.self)!
    
    fileprivate weak var controller: UIViewController?
    
    
    init(controller: UIViewController) {
        
        self.controller = controller
        super.init()
    }
    
    func bodyView(for state: AKFLoginFlowState) -> UIView? {
        
        if state != .phoneNumberInput {
            
            return nil
        }
        
        let cell = UIView.loadFromNib(view: STTermsCustomView.self)!
        
        cell.backgroundColor = UIColor.red
        
        let text = String(format: "login_page_offer_text".localized,
                          "login_offer_text".localized, "login_terms_text".localized)
        
        let style = NSNumber(integerLiteral: NSUnderlineStyle.styleSingle.rawValue)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        paragraphStyle.alignment = .center
        
        let attributedText = NSMutableAttributedString(string: text,
                                                       attributes: [ NSFontAttributeName : UIFont.systemFont(ofSize: 11),
                                                                     NSParagraphStyleAttributeName : paragraphStyle ])
        
        let range1 = attributedText.mutableString.range(of: "login_offer_text".localized, options: .caseInsensitive)
        let range2 = attributedText.mutableString.range(of: "login_terms_text".localized, options: .caseInsensitive)
        
        let attr: [String : Any] = [NSFontAttributeName : UIFont.systemFont(ofSize: 11),
                                    NSUnderlineStyleAttributeName : style]
        
        attributedText.setAttributes(attr, range: range1)
        attributedText.setAttributes(attr, range: range2)

        let label = self.container.label!
        
        label.numberOfLines = 0
        label.isUserInteractionEnabled = true
        label.attributedText = attributedText
        label.clikableRanges = [range1, range2]
        label.onTextClikAction = { range in
            
            switch (range.location, range.length) {
                
            case (range1.location, range1.length):
                
                print("open offer")
                
                if let path = Bundle.main.path(forResource: "privacy-policy", ofType: "docx") {
                    
                    self.controller?.st_router_openDocumentController(url: URL(fileURLWithPath: path),
                                                                      title: "settings_terms_&_condictions_text".localized)
                }
                
                break
                
            case (range2.location, range2.length):
                
                print("open terms")
                
                if let path = Bundle.main.path(forResource: "privacy-policy", ofType: "docx") {
                    
                    self.controller?.st_router_openDocumentController(url: URL(fileURLWithPath: path),
                                                                      title: "settings_terms_&_condictions_text".localized)
                }
                
                break
                
            default:
                break
            }
        }

        return container
    }
}

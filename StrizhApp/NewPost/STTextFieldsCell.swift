//
//  STTextFieldsCell.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 08/03/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import ReactiveKit

class STTextFieldsCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var leftValue: UITextField!
    
    @IBOutlet weak var rightValue: UITextField!
    
    var onLeftErrorHandler: (() -> Void)?
    
    var onRightErrorHandler: (() -> Void)?
    
    var onLeftValueShouldBeginEditing: (() -> Void)?
    
    var onRightValueShouldBeginEditing: (() -> Void)?
    
    var bag = DisposeBag()
    
    
    deinit {
        
        bag.dispose()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        title.text = ""
        leftValue.placeholder = ""
        rightValue.placeholder = ""
        
        selectionStyle = .none
        
        leftValue.delegate = self
        rightValue.delegate = self
    }
    
    override func prepareForReuse() {
        
        bag.dispose()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField == leftValue {
            
            onLeftValueShouldBeginEditing?()
        }
        
        if textField == rightValue {
            
            onRightValueShouldBeginEditing?()
        }
        
        return false
    }
    
    func showLeftError() {
        
        let button = UIButton(type: .custom)
        button.bounds = CGRect(x: 0, y: 0, width: 16, height: 16)
        button.setImage(UIImage(named: "icon-error"), for: .normal)
        
        button.reactive.tap.observeNext { [unowned self] _ in
            
            self.onLeftErrorHandler?()
            
        }.dispose(in: bag)
        
        self.leftValue.rightView = button
        self.leftValue.rightViewMode = .unlessEditing
    }
    
    func showRightError() {
        
        let button = UIButton(type: .custom)
        button.bounds = CGRect(x: 0, y: 0, width: 16, height: 16)
        button.setImage(UIImage(named: "icon-error"), for: .normal)
        
        button.reactive.tap.observeNext { [unowned self] _ in
            
            self.onRightErrorHandler?()
            
        }.dispose(in: bag)
        
        self.rightValue.rightView = button
        self.rightValue.rightViewMode = .unlessEditing
    }
    
    func hideLeftError() {
        
        self.leftValue.rightView = nil
    }
    
    func hideRightError() {
        
        self.rightValue.rightView = nil
    }
}

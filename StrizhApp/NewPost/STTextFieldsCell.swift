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
    
    var disposeBag = DisposeBag()
    
    
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
        
        disposeBag = DisposeBag()
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        
        textField.text = ""
        return false
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
        button.setImage(UIImage(named: "icon-error"), for: .normal)
        button.bounds = CGRect(x: 0, y: 0, width: 16, height: 16)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -1, bottom: 0, right: 1)
        
        button.reactive.tap.observeNext { [unowned self] _ in
            
            self.onLeftErrorHandler?()
            
        }.dispose(in: disposeBag)
        
        self.leftValue.rightView = button
        self.leftValue.rightViewMode = .always
    }
    
    func showRightError() {
        
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "icon-error"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -1, bottom: 0, right: 1)
        button.bounds = CGRect(x: 0, y: 0, width: 16, height: 16)
        
        button.reactive.tap.observeNext { [unowned self] _ in
            
            self.onRightErrorHandler?()
            
        }.dispose(in: disposeBag)
        
        self.rightValue.rightView = button
        self.rightValue.rightViewMode = .always
    }
    
    func hideLeftError() {
        
        self.leftValue.rightView = nil
    }
    
    func hideRightError() {
        
        self.rightValue.rightView = nil
    }
}

//
//  STTextFieldCell.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 02/03/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import ReactiveKit

class STTextFieldCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var value: UITextField!
    
    var onErrorHandler: (() -> Void)?
    
    var onTextDidChange: ((_ text: String) -> Void)?
    
    var disposeBag = DisposeBag()
    
    
    deinit {
        
        disposeBag.dispose()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        title.text = ""
        value.placeholder = ""
        value.text = ""
        
        value.addTarget(self, action: #selector(self.textDidChange), for: .editingChanged)
        
        selectionStyle = .none
    }

    override func prepareForReuse() {
        
        disposeBag.dispose()
        title.text = ""
        value.placeholder = ""
        value.text = ""
        value.keyboardType = .default
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func showError() {
        
        let button = UIButton(type: .custom)
        button.bounds = CGRect(x: 0, y: 0, width: 16, height: 16)
        button.setImage(UIImage(named: "icon-error"), for: .normal)
        
        button.reactive.tap.observeNext { [unowned self] _ in
            
            self.onErrorHandler?()
            
        }.dispose(in: disposeBag)
        
        self.value.rightView = button
        self.value.rightViewMode = .always
    }
    
    func hideError() {
        
        self.value.rightView = nil
    }
    
    @objc func textDidChange() {
        
        if let text = value.text {
            
            onTextDidChange?(text)
        }
    }
}

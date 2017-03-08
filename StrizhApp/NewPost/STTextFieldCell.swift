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
    
    var bag = DisposeBag()
    
    
    deinit {
        
        bag.dispose()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        title.text = ""
        value.placeholder = ""
        value.text = ""
        
        selectionStyle = .none
    }

    override func prepareForReuse() {
        
        title.text = ""
        value.placeholder = ""
        value.text = ""
        value.keyboardType = .default
        bag.dispose()
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
            
        }.dispose(in: bag)
        
        self.value.rightView = button
        self.value.rightViewMode = .always
    }
    
    func hideError() {
        
        self.value.rightView = nil
    }
}

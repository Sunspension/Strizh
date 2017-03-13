//
//  STTextViewCell.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 13/03/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit

class STTextViewCell: UITableViewCell, UITextViewDelegate {

    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak private var value: UITextView!
    
    @IBOutlet weak var placeHolder: UITextField!
    
    var onTextViewDidChange: ((_ textView: UITextView) -> Void)?
    
    var onReturn: (() -> Void)?
    
    var textValue: String? {
        
        get {
            
            return value.text
        }
        
        set {
            
            value.text = newValue
            self.placeHolder.isHidden = !(newValue ?? "").isEmpty
        }
    }
    
    override func prepareForReuse() {
        
        title.text = ""
        value.text = ""
        placeHolder.isHidden = false
        onTextViewDidChange = nil
        onReturn = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        title.text = ""
        value.text = ""
        value.delegate = self
        value.textContainerInset = UIEdgeInsets(top: 2, left: -4, bottom: 4, right: 0)
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n" {
            
            onReturn?()
            return false
        }
        
        self.placeHolder.isHidden = !textView.text.isEmpty
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        self.placeHolder.isHidden = !textView.text.isEmpty
        self.onTextViewDidChange?(textView)
    }
}

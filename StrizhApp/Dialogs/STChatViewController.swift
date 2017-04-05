//
//  STChatViewController.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 28/03/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import AlamofireImage

class STChatViewController: STChatControllerBase, UITextViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var bottomToolbar: UIView!
    
    @IBOutlet weak var placeHolder: UITextField!
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var bottomToolbarSpace: NSLayoutConstraint!
    
    
    fileprivate var dataSource = CollectionViewDataSource()
    
    fileprivate var section = CollectionSection()
    
    fileprivate var myUser: STUser!
    
    
    var users: [STUser] = []
    
    var itemsSource: [STMessage] = [] {
        
        didSet {
            
            self.createDataSource()
            self.collectionView.reloadData()
            self.scrollToLastMessage()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.textView.layer.cornerRadius = 5
        self.textView.clipsToBounds = true
        self.textView.delegate = self
        self.textView.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
        
        let tapRecognaizer = UITapGestureRecognizer(target: self, action: #selector(self.tapGestureHandler))
        tapRecognaizer.numberOfTapsRequired = 1
        tapRecognaizer.numberOfTouchesRequired = 1
        
        self.view.addGestureRecognizer(tapRecognaizer)
        
        self.sendButton.addTarget(self, action: #selector(self.sendMessage), for: .touchUpInside)
        
        self.myUser = STUser.objects(by: STUser.self).first!
        
        self.collectionView.delegate = self.dataSource
        self.collectionView.dataSource = self.dataSource
        
        self.dataSource.sections.append(self.section)
    }

    override func keyboardWillShow(_ notification: Notification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size {

            self.bottomToolbarSpace.constant = keyboardSize.height
            self.textView.contentOffset = CGPoint.zero
            self.textView.contentInset = UIEdgeInsets.zero
            self.scrollToLastMessage()
            
            UIView.animate(withDuration: 0.3, animations: { 
                
                self.view.layoutIfNeeded()
            })
        }
    }
    
    override func keyboardWillHide(_ notification: Notification) {
        
        self.bottomToolbarSpace.constant = 0
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.view.layoutIfNeeded()
            self.bottomToolbar.layoutIfNeeded()
        })
    }

    func sendMessage() {
        
        let text = self.textView.text.trimmingCharacters(in: .whitespaces)
        let createdAt = Date()
        let userId = self.myUser.id
        
        let message = STMessage(message: text, createdAt: createdAt, userId: userId)
        
        let itemIndex = self.section.addItem(cellClass: STDialogMyCell.self, item: message,
                                             bindingAction: self.myCellBindingAction)
        
        let indexPath = IndexPath(item: itemIndex!, section: 0)
        
        self.textView.text = ""
        self.placeHolder.isHidden = false
        
        self.collectionView.insertItems(at: [indexPath])
        self.scrollToLastMessage()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        self.placeHolder.isHidden = !textView.text.isEmpty
    }
    
    func tapGestureHandler(tapRecognizer: UITapGestureRecognizer) {
        
        if tapRecognizer.state != .recognized {
            
            return
        }
        
        self.view.endEditing(true)
    }
    
    fileprivate func createDataSource() {
        
        for message in self.itemsSource {
            
            if message.userId == self.myUser.id {
                
                self.section.addItem(cellClass: STDialogMyCell.self, item: message,
                                     bindingAction: self.myCellBindingAction)
            }
            else {
                
                self.section.addItem(cellClass: STDialogOtherCell.self,
                                     item: message,
                                     bindingAction: { [unowned self] (cell, item) in
                                        
                                        let viewCell = cell as! STDialogOtherCell
                                        let message = item.item as! STMessage
                                        
                                        viewCell.text.text = message.message
                                        viewCell.time.text = message.createdAt.time
                                        
                                        viewCell.setNeedsLayout()
                                        viewCell.layoutIfNeeded()
                                        
                                        if let user = self.users.first(where: { $0.id == message.userId }) {
                                            
                                            let urlString = user.imageUrl + self.queryResizeString(imageView: viewCell.userImage.imageView!)
                                            
                                            let filter = RoundedCornersFilter(radius: CGFloat(viewCell.userImage.imageView!.bounds.width))
                                            
                                            viewCell.userImage.af_setImage(for: .normal, url: URL(string: urlString)!, filter: filter)
                                        }
                                        
                })
            }
        }
    }
    
    fileprivate func queryResizeString(imageView: UIImageView) -> String {
        
        let width = Int(imageView.bounds.size.width * UIScreen.main.scale)
        let height = Int(imageView.bounds.size.height * UIScreen.main.scale)
        
        return "?resize=w[\(width)]h[\(height)]q[100]e[true]"
    }
    
    fileprivate func scrollToLastMessage() {
        
        self.collectionView.setNeedsLayout()
        self.collectionView.layoutIfNeeded()
        
        guard self.section.items.count != 0 else {
            
            return
        }
        
        let item = self.section.items.last!
        let index = self.section.items.index(of: item)!
        let indexPath = IndexPath(item: index, section: 0)
        
        self.collectionView.scrollToItem(at: indexPath, at: .top, animated: false)
    }
    
    fileprivate func myCellBindingAction(cell: UICollectionViewCell, item: CollectionSectionItem) {
        
        let viewCell = cell as! STDialogMyCell
        let message = item.item as! STMessage
        
        viewCell.text.text = message.message
        viewCell.time.text = message.createdAt.time
        
        viewCell.setNeedsLayout()
        viewCell.layoutIfNeeded()
        
        if let user = self.users.first(where: { $0.id == message.userId }) {
            
            let urlString = user.imageUrl + self.queryResizeString(imageView: viewCell.userImage.imageView!)
            
            let filter = RoundedCornersFilter(radius: CGFloat(viewCell.userImage.imageView!.bounds.width))
            
            viewCell.userImage.af_setImage(for: .normal, url: URL(string: urlString)!, filter: filter)
        }
    }
    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}

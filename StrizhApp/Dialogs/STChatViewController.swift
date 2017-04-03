//
//  STChatViewController.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 28/03/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import AlamofireImage

class STChatViewController: STChatControllerBase {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var bottomToolbar: UIView!
    
    @IBOutlet weak var placeHolder: UITextField!
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var bottomToolbarSpace: NSLayoutConstraint!
    
    
    fileprivate var dataSource = CollectionViewDataSource()
    
    fileprivate var section = CollectionSection()
    
    fileprivate var myUser: STUser!
    
    fileprivate var originalContentInset = UIEdgeInsets.zero
    
    
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
        
        textView.layer.cornerRadius = 5
        textView.clipsToBounds = true
        
        self.myUser = STUser.objects(by: STUser.self).first!
        
        self.collectionView.delegate = self.dataSource
        self.collectionView.dataSource = self.dataSource
        
        self.dataSource.sections.append(self.section)
    }

    override func keyboardWillShow(_ notification: Notification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size {

            self.bottomToolbarSpace.constant = keyboardSize.height
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
        })
    }

    fileprivate func createDataSource() {
        
        for message in self.itemsSource {
            
            if message.userId == self.myUser.id {
                
                self.section.addItem(cellClass: STDialogMyCell.self,
                                     item: message,
                                     bindingAction: { [unowned self] (cell, item) in
                                        
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
                })
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
        
        let item = self.section.items.last!
        let index = self.section.items.index(of: item)!
        let indexPath = IndexPath(item: index, section: 0)
        
        self.collectionView.scrollToItem(at: indexPath, at: .top, animated: false)
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

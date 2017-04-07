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
    
    
    fileprivate let dataSource = TableViewDataSource()
    
    fileprivate let section = TableSection()
    
    fileprivate var myUser: STUser!
    
    fileprivate var loadingStatus = STLoadingStatusEnum.idle
    
    fileprivate var lastId: Int? = nil
    
    fileprivate var hasMore = false
    
    fileprivate var pageSize = 20
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var bottomToolbar: UIView!
    
    @IBOutlet weak var placeHolder: UITextField!
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var bottomToolbarSpace: NSLayoutConstraint!
    
    var dialog: STDialog!
    
    var users: [STUser] = []
    
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = self.dialog.title
        
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
        
        self.tableView.delegate = self.dataSource
        self.tableView.dataSource = self.dataSource
        
        self.dataSource.sections.append(self.section)
        
        self.tableView.estimatedRowHeight = 77 // magic number
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = .none
        
        self.loadMessages()
    }

    override func keyboardWillShow(_ notification: Notification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size {

            self.bottomToolbarSpace.constant = keyboardSize.height
            self.textView.contentOffset = CGPoint.zero
            self.textView.contentInset = UIEdgeInsets.zero
            
            self.tableView.setNeedsLayout()
            self.tableView.layoutIfNeeded()
            
            self.scrollToLastMessage()
            
            UIView.animate(withDuration: 0.3, animations: { 
                
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            })
        }
    }
    
    override func keyboardWillHide(_ notification: Notification) {
        
        self.bottomToolbarSpace.constant = 0
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        })
    }

    func sendMessage() {
        
        let text = self.textView.text.trimmingCharacters(in: .whitespaces)
        
        guard !text.isEmpty else {
            
            return
        }
        
        let createdAt = Date()
        let userId = self.myUser.id
        
        let message = STMessage(message: text, createdAt: createdAt, userId: userId)
        
        self.section.addItem(cellClass: STDialogMyCell.self, item: message,
                             bindingAction: self.myCellBindingAction)
        
        self.textView.text = ""
        self.placeHolder.isHidden = false
        self.tableView.reloadData()
        self.scrollToLastMessage(animated: true)
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
    
    fileprivate func loadMessages(loadMore: Bool = false, initialIndexPath: IndexPath? = nil) {
        
        self.loadingStatus = .loading
        self.tableView.showBusy()
        
        api.loadDialogMessages(dialog: dialog, pageSize: self.pageSize, lastId: self.lastId)
            
            .onSuccess { messages in
                
                self.tableView.hideBusy()
                self.loadingStatus = .loaded
                
                if let lastMessage = messages.last {
                
                    self.lastId = lastMessage.id
                }
                
                self.hasMore = messages.count == self.pageSize
                
                self.createDataSource(messages: messages)
                
                
                if loadMore {
                 
                    let sizeBefore = self.tableView.contentSize
                    
                    self.tableView.reloadData()
                    
                    self.tableView.setNeedsLayout()
                    self.tableView.layoutIfNeeded()
                    
                    let sizeAfter = self.tableView.contentSize
                    let offSet = self.tableView.contentOffset
                    
                    let newOffsetY = offSet.y + sizeAfter.height - sizeBefore.height
                    
                    self.tableView.contentOffset = CGPoint(x: 0, y: newOffsetY)
                }
                else {
                    
                    self.tableView.reloadData()
                    self.scrollToLastMessage()
                }
                
            }.onFailure { error in
                
                self.loadingStatus = .failed
                self.tableView.hideBusy()
                
                self.showError(error: error)
        }
    }
    
    fileprivate func createDataSource(messages: [STMessage]) {
        
        for message in messages {
            
            if message.userId == self.myUser.id {
                
                self.section.insert(item: message, at: 0, cellClass: STDialogMyCell.self,
                                    bindingAction: self.myCellBindingAction)
            }
            else {
                
                self.section.insert(item: message, at: 0, cellClass: STDialogOtherCell.self,
                                     bindingAction: { [unowned self] (cell, item) in
                                        
                                        if item.indexPath.row - 10 < 0 && self.hasMore
                                            && self.loadingStatus != .loading {
                                            
                                            self.loadMessages(loadMore: true,
                                                              initialIndexPath: item.indexPath)
                                        }
                                        
                                        let viewCell = cell as! STDialogOtherCell
                                        let message = item.item as! STMessage
                                        
                                        viewCell.messageText.text = message.message
                                        viewCell.time.text = message.createdAt.time
                                        
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
    
    fileprivate func scrollToLastMessage(animated: Bool = false) {
        
        guard self.section.items.count != 0 else {
            
            return
        }
        
        let item = self.section.items.last!
        let index = self.section.items.index(of: item)!
        let indexPath = IndexPath(item: index, section: 0)
        
        self.tableView.scrollToRow(at: indexPath, at: .top, animated: animated)
    }
    
    fileprivate func myCellBindingAction(cell: UITableViewCell, item: TableSectionItem) {
        
        if item.indexPath.row - 10 < 0 && self.hasMore
            && self.loadingStatus != .loading {
            
            self.loadMessages(loadMore: true,
                              initialIndexPath: item.indexPath)
        }
        
        let viewCell = cell as! STDialogMyCell
        let message = item.item as! STMessage
        
        viewCell.messageText.text = message.message
        viewCell.time.text = message.createdAt.time
        
        if let user = self.users.first(where: { $0.id == message.userId }) {
            
            let urlString = user.imageUrl + self.queryResizeString(imageView: viewCell.userImage.imageView!)
            
            let filter = RoundedCornersFilter(radius: CGFloat(viewCell.userImage.imageView!.bounds.width))
            
            viewCell.userImage.af_setImage(for: .normal, url: URL(string: urlString)!, filter: filter)
        }
    }
}

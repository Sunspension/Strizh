//
//  STChatViewController.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 28/03/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import AlamofireImage
import ReactiveKit

class STChatViewController: STChatControllerBase, UITextViewDelegate {
    
    
    fileprivate let dataSource = TableViewDataSource()
    
    fileprivate var myUser: STUser!
    
    fileprivate var loadingStatus = STLoadingStatusEnum.idle
    
    fileprivate var lastId: Int? = nil
    
    fileprivate var hasMore = false
    
    fileprivate var pageSize = 20
    
    fileprivate let disposeBag = DisposeBag()
    
    
    var postId: Int?
    
    var objectType: Int?
    
    var dialog: STDialog?
    
    var users: [STUser] = []
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var bottomToolbar: UIView!
    
    @IBOutlet weak var placeHolder: UITextField!
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var bottomToolbarSpace: NSLayoutConstraint!
    
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
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
        
        self.sendButton.addTarget(self, action: #selector(self.sendMessageAction), for: .touchUpInside)
        
        self.myUser = STUser.objects(by: STUser.self).first!
        
        self.tableView.delegate = self.dataSource
        self.tableView.dataSource = self.dataSource
        
        self.tableView.estimatedRowHeight = 77 // magic number
        self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor.white
        self.tableView.separatorStyle = .none
        self.tableView.register(headerFooterNibClass: STDialogSectionHeader.self)
        
        NotificationCenter.default.reactive.notification(name: NSNotification.Name(kReceiveMessageNotification), object: nil)
            .observeNext { [unowned self] notification in
                
                guard let dialog = self.dialog else {
                    
                    return
                }
                
                let message = (notification.object as? STMessage)!
                
                if message.dialogId != dialog.id {
                    
                    return
                }
                
                // notify
                self.notifyMessagesRead(lastReadMessage: message.id)
                
                let section = self.section(by: message.createdAt)
                let itemIndex = section.addItem(cellClass: STDialogMyCell.self, item: message,
                                                bindingAction: self.myCellBindingAction)
                
                let sectionIndex = self.dataSource.sections.index(of: section)
                let indexPath = IndexPath(item: itemIndex, section: sectionIndex!)
                
                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                
            }.dispose(in: disposeBag)
        
        if self.dialog == nil {
            
            if let postId = self.postId, let objectType = self.objectType {
                
                self.tableView.showBusy()
                
                api.createDialog(objectId: postId, objectType: objectType, message: nil)
                    .onSuccess { [weak self] dialog in
                        
                        self?.tableView.hideBusy()
                        
                        self?.dialog = dialog
                        
                        // TODO load apponent id
                        self?.loadMessages()
                    }
                    .onFailure { [weak self] error in
                        
                        self?.tableView.hideBusy()
                    }
            }
            
            return
        }
        
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

    /// Object type = 1 - Dialog with user
    /// Object type = 2 - Dialog with support
    func loadDialog(by objectId: Int, objectType: Int) {
        
       
    }
    
    func sendMessageAction() {
        
        let text = self.textView.text.trimmingCharacters(in: .whitespaces)
        
        guard !text.isEmpty else {
            
            return
        }
        
        let createdAt = Date()
        let userId = self.myUser.id
        
        let message = STMessage(message: text, createdAt: createdAt, userId: userId)
        
        let section = self.section(by: Date())
        
        let messageIndex = section.addItem(cellClass: STDialogMyCell.self, item: message,
                                            bindingAction: self.myCellBindingAction)
        
        self.textView.text = ""
        self.placeHolder.isHidden = false
        self.tableView.reloadData()
        self.scrollToLastMessage(animated: true)
        
        self.sendMessage(message: text, section: section, messageIndex: messageIndex)
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
    
    fileprivate func section(by date: Date) -> TableSection {
        
        var section = self.dataSource.sections.last
        
        if section == nil {
            
            section = TableSection()
            section!.sectionType = date
            section!.header(headerClass: STDialogSectionHeader.self,
                            item: date.dayMonthFormat,
                            bindingAction: { (cell, item) in
                                
                                let header = cell as! STDialogSectionHeader
                                let date = item.item as! String
                                header.dateLabel.text = date
            })
            
            section?.headerItem?.cellHeight = 30
            
            self.dataSource.sections.append(section!)
        }
        
        return section!
    }
    
    fileprivate func sendMessage(message: String, section: TableSection, messageIndex: Int) {
        
        let errorClosure = {
            
            let alert = UIAlertController(title: "Ошибка",
                                          message: "Не удалось отправить сообщение",
                                          preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Удалить сообщение",
                                       style: .cancel, handler: { [unowned self] action in
                                        
                                        section.items.remove(at: messageIndex)
                                        
                                        let sectionIndex = self.dataSource.sections.index(of: section)!
                                        let indexPath = IndexPath(item: messageIndex, section: sectionIndex)
                                        
                                        self.tableView.deleteRows(at: [indexPath], with: .automatic)
            })
            
            let resend = UIAlertAction(title: "Попробовать еще раз",
                                       style: .default, handler: { [weak self] action in
                                        
                                        self?.sendMessage(message: message, section: section,
                                                          messageIndex: messageIndex)
            })
            
            alert.addAction(cancel)
            alert.addAction(resend)
            
            self.present(alert, animated: true, completion: nil)
        }
        
        if let dialog = self.dialog {
            
            api.sendMessage(dialogId: dialog.id, message: message)
                .onFailure { error in
                    
                    errorClosure()
                }
        }
        else if let postId = self.postId, let objectType = self.objectType {
            
            api.createDialog(objectId: postId, objectType: objectType, message: message)
                .onSuccess(callback: { dialog in
                
                    self.dialog = dialog
                })
                .onFailure(callback: { error in
                    
                    errorClosure()
                })
        }
    }
    
    fileprivate func notifyMessagesRead(lastReadMessage: Int) {
        
        api.notifyMessagesRead(dialogId: self.dialog!.id, lastMessageId: lastReadMessage)
            .onSuccess { dialog in
            
                NotificationCenter.default.post(name: NSNotification.Name(kPostUpdateDialogNotification),
                                                object: dialog)
            }
    }
    
    fileprivate func loadMessages(loadMore: Bool = false) {
        
        guard let dialog = self.dialog else {
            
            return
        }
        
        self.loadingStatus = .loading
        self.tableView.showBusy()
        
        api.loadDialogMessages(dialogId: dialog.id, pageSize: self.pageSize, lastId: self.lastId)
            
            .onSuccess { [unowned self] messages in
                
                self.tableView.hideBusy()
                self.loadingStatus = .loaded
                
                if let lastMessage = messages.last {
                
                    self.lastId = lastMessage.id
                    
                    if !loadMore && dialog.unreadMessageCount != 0 {
                        
                        // notify
                        if let message = messages.first(where: { $0.userId != self.myUser.id }) {
                            
                            self.notifyMessagesRead(lastReadMessage: message.id)
                        }
                    }
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
            
            var section = self.dataSource.sections.first(where: { section -> Bool in
                
                if let sectionDate = section.sectionType as? Date {
                    
                   if sectionDate.year == message.createdAt.year
                    && sectionDate.month == message.createdAt.month
                    && sectionDate.day == message.createdAt.day {
                    
                        return true
                    }
                }
                
                return false
            })
            
            if section == nil {
                
                section = TableSection()
                section!.sectionType = message.createdAt
                section!.header(headerClass: STDialogSectionHeader.self,
                                item: message.createdAt.dayMonthFormat,
                                bindingAction: { (cell, item) in
                                    
                                    let header = cell as! STDialogSectionHeader
                                    let date = item.item as! String
                                    header.dateLabel.text = date
                })
                
                section?.headerItem?.cellHeight = 30
                
                self.dataSource.sections.insert(section!, at: 0)
            }
            
            if message.userId == self.myUser.id {
                
                section!.insert(item: message, at: 0, cellClass: STDialogMyCell.self,
                                    bindingAction: self.myCellBindingAction)
            }
            else {
                
                section!.insert(item: message, at: 0, cellClass: STDialogOtherCell.self,
                                     bindingAction: { [unowned self] (cell, item) in
                                        
                                        let section = self.dataSource.sections.first!
                                        
                                        if section.items.contains(item)
                                            && item.indexPath.row - 10 < 0 && self.hasMore
                                            && self.loadingStatus != .loading {
                                            
                                            self.loadMessages(loadMore: true)
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
        
        guard self.dataSource.sections.flatMap({ $0.items }).count != 0 else {
            
            return
        }
        
        let section = self.dataSource.sections.last!
        let item = section.items.last!
        let itemIndex = section.items.index(of: item)!
        let sectionIndex = self.dataSource.sections.index(of: section)
        
        let indexPath = IndexPath(item: itemIndex, section: sectionIndex!)
        
        self.tableView.scrollToRow(at: indexPath, at: .top, animated: animated)
    }
    
    fileprivate func myCellBindingAction(cell: UITableViewCell, item: TableSectionItem) {
        
        let section = self.dataSource.sections.first!
        
        if section.items.contains(item)
            && item.indexPath.row - 10 < 0 && self.hasMore
            && self.loadingStatus != .loading {
            
            self.loadMessages(loadMore: true)
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

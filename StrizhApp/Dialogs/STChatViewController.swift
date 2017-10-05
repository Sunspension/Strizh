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
import Bond

class STChatViewController: UIViewController, UITextViewDelegate {
    
    fileprivate let dataSource = TableViewDataSource()
    
    fileprivate var loadingStatus = STLoadingStatusEnum.idle
    
    fileprivate var lastId: Int64? = nil
    
    fileprivate var hasMore = false
    
    fileprivate var pageSize = 20
    
    fileprivate let disposeBag = DisposeBag()
    
    fileprivate var messages = Set<STMessage>()
    
    fileprivate var myUser: STUser {
        
        return STUser.objects(by: STUser.self).first!
    }
    
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
    

    deinit {
        
        NotificationCenter.default.removeObserver(self)
    }

    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.analytics.logEvent(eventName: st_eDialog, timed: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        self.analytics.endTimeEvent(eventName: st_eDialog)
        
        // checking press back button
        if self.navigationController?.viewControllers.index(of: self) == nil {
            
            guard let dialog = self.dialog else {
                
                return
            }
            
            self.analytics.endTimeEvent(eventName: st_eBackToDialogList,
                                        params: ["post_id" : dialog.postId, "dialog_id" : dialog.id])
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
        
        self.sendButton.addTarget(self, action: #selector(self.sendMessageAction), for: .touchUpInside)
        
        self.tableView.delegate = self.dataSource
        self.tableView.dataSource = self.dataSource
        
        self.tableView.estimatedRowHeight = 77 // magic number
        self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor.white
        self.tableView.separatorStyle = .none
        self.tableView.register(headerFooterNibClass: STDialogSectionHeader.self)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.onMessageReceive),
                                               name: Notification.Name(kReceiveMessageNotification),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillShow),
                                               name: Notification.Name.UIKeyboardWillShow,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillHide),
                                               name: Notification.Name.UIKeyboardWillHide,
                                               object: nil)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon-more"),
                                                                 style: .plain, target: self, action: #selector(self.openFilterAction))
        
        setCustomBackButton()
        self.loadNecessaryDataIfNeeded()
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size {

            self.bottomToolbarSpace.constant = keyboardSize.height
            self.textView.contentOffset = CGPoint.zero
            self.textView.contentInset = UIEdgeInsets.zero
            
            self.tableView.setNeedsLayout()
            self.tableView.layoutIfNeeded()
            
            if let dummy = self.dummyView() {
                
                dummy.center.y -= keyboardSize.height
            }
            
            self.scrollToLastMessage()
            
            UIView.animate(withDuration: 0.3, animations: { 
                
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        
        if let dummy = self.dummyView() {
            
            dummy.center.y += self.bottomToolbarSpace.constant
        }
        
        self.bottomToolbarSpace.constant = 0
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        })
    }
    
    @objc func onMessageReceive(notification: Notification) {
        
        guard let dialog = self.dialog else {
            
            return
        }
        
        let message = (notification.object as? STMessage)!
        
        if message.dialogId != dialog.id
            || message.userId == self.myUser.id {
            
            return
        }
        
        self.messages.insert(message)
        
        self.analytics.logEvent(eventName: st_eDialogReceiveMessage,
                                params: ["post_id" : dialog.postId, "dialog_id" : dialog.id])
        
        // notify
        self.notifyMessagesRead(lastReadMessage: message.id)
        
        self.createDataSource()
        self.reloadTableView()
        self.scrollToLastMessage(animated: true)
    }
    
    @objc func sendMessageAction() {
        
        let text = self.textView.text.trimmingCharacters(in: .whitespaces)
        
        guard !text.isEmpty else {
            
            return
        }
        
        let createdAt = Date()
        let userId = self.myUser.id
        
        let message = STMessage(message: text, createdAt: createdAt, userId: userId)
        
        var section = self.section(by: createdAt)
        
        if section == nil {
            
            section = self.newSection(date: Date())
            self.dataSource.sections.append(section!)
        }
        
        let messageIndex = section!.add(item: message, cellClass: STDialogMyCell.self) { [unowned self] (cell, item) in
            
            self.myCellBindingAction(cell: cell, item: item)
        }
        
        self.textView.text = ""
        self.placeHolder.isHidden = false
        
        let sectionIndex = self.dataSource.sections.index(of: section!)
        let indexPath = IndexPath(item: messageIndex, section: sectionIndex!)
        
        self.reloadTableView()
        self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        
        if let dialog = self.dialog {
            
            let postId = self.postId ?? dialog.postId
            
            self.analytics.logEvent(eventName: st_eSendMessage, params: ["post_id" : postId, "dialog_id" : dialog.id])
        }
        
        self.sendMessage(message: text, section: section!, messageIndex: messageIndex)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        self.placeHolder.isHidden = !textView.text.isEmpty
    }
    
    @objc func tapGestureHandler(tapRecognizer: UITapGestureRecognizer) {
        
        if tapRecognizer.state != .recognized {
            
            return
        }
        
        self.view.endEditing(true)
    }
    
    @objc func openFilterAction() {
        
        let controller = UIAlertController(title: nil, message: nil,preferredStyle: .actionSheet)
        
        let openDetailsAction = UIAlertAction(title: "chat_filter_action_go_to_post_details_text".localized,
                                              style: .default) { action in
                                                
                                                guard self.dialog != nil else { return }
                                                self.st_router_openPostDetails(postId: self.dialog!.postId)
        }
        
        let cancel = UIAlertAction(title: "action_cancel".localized, style: .cancel, handler: nil)
        
        controller.addAction(openDetailsAction)
        controller.addAction(cancel)
        
        self.present(controller, animated: true, completion: nil)
    }

    
    // MARK: - Private methods
    fileprivate func section(by date: Date) -> TableSection? {
        
        let section = self.dataSource.sections.first(where: { section -> Bool in
            
            if let sectionDate = section.sectionType as? Date {
                
                return sectionDate.isTheSameDay(date: date)
            }
            
            return false
        })
        
        return section
    }
    
    fileprivate func sendMessage(message: String, section: TableSection, messageIndex: Int) {
        
        guard let dialog = self.dialog else {
            
            return
        }
        
        api.sendMessage(dialogId: dialog.id, message: message)
            .onSuccess(callback: { [unowned self] message in
            
                self.messages.insert(message)
            })
            .onFailure { [unowned self] error in
                
                let alert = UIAlertController(title: "alert_title_error".localized,
                                              message: "alert_chat_can't_send_message".localized,
                                              preferredStyle: .alert)
                let cancel = UIAlertAction(title: "alert_title_delete_chat_message".localized,
                                           style: .cancel, handler: { [unowned self] action in
                                            
                                            section.items.remove(at: messageIndex)
                                            
                                            let sectionIndex = self.dataSource.sections.index(of: section)!
                                            let indexPath = IndexPath(item: messageIndex, section: sectionIndex)
                                            
                                            self.tableView.deleteRows(at: [indexPath], with: .automatic)
                })
                
                let resend = UIAlertAction(title: "alert_title_chat_try_again".localized,
                                           style: .default, handler: { [unowned self] action in
                                            
                                            self.sendMessage(message: message, section: section,
                                                              messageIndex: messageIndex)
                })
                
                alert.addAction(cancel)
                alert.addAction(resend)
                
                self.present(alert, animated: true, completion: nil)
        }
    }
    
    fileprivate func notifyMessagesRead(lastReadMessage: Int64?) {
        
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
        
        self.analytics.logEvent(eventName: st_eDialogScroll,
                                params: ["post_id" : dialog.postId, "dialog_id" : dialog.id])
        
        api.loadDialogMessages(dialogId: dialog.id, pageSize: self.pageSize, lastId: self.lastId)

            .onSuccess { [unowned self] messages in
                
                self.tableView.hideBusy()
                self.loadingStatus = .loaded
                
                if let lastMessage = messages.last {
                
                    self.lastId = lastMessage.id
                    
                    if !loadMore && dialog.unreadMessageCount != 0 {
                        
                        if let firstMessage = messages.first {
                            
                            let lastMessageId = firstMessage.userId == self.myUser.id ?
                                firstMessage.lastMessageId : firstMessage.id
                            
                            // notify
                            self.notifyMessagesRead(lastReadMessage: lastMessageId)
                        }
                    }
                }
                
                self.hasMore = messages.count == self.pageSize
                
                for message in messages {
                    
                    self.messages.insert(message)
                }
                
                self.createDataSource()
                
                if loadMore {
                 
                    let sizeBefore = self.tableView.contentSize
                    let offSet = self.tableView.contentOffset
                    
                    self.reloadTableView()
                    self.tableView.layoutIfNeeded()
                    
                    let sizeAfter = self.tableView.contentSize
                    let newOffsetY = offSet.y + sizeAfter.height - sizeBefore.height
                    
                    self.tableView.contentOffset = CGPoint(x: 0, y: newOffsetY)
                }
                else {
                    
                    self.reloadTableView()
                    self.scrollToLastMessage()
                }
            }
            .onFailure { [unowned self] error in
                
                self.loadingStatus = .failed
                self.tableView.hideBusy()
                
                self.showError(error: error)
            }
    }
    
    fileprivate func createDataSource() {
        
        self.dataSource.sections.removeAll()
        
        for message in self.messages.sorted(by: { $0.id > $1.id }) {
            
            var section = self.section(by: message.createdAt)
            
            if section == nil {
                
                section = self.newSection(date: message.createdAt)
                self.dataSource.sections.insert(section!, at: 0)
            }
            
            if message.userId == self.myUser.id {
                
                section!.insert(item: message, at: 0, cellClass: STDialogMyCell.self) { [unowned self] (cell, item) in
                    
                    self.myCellBindingAction(cell: cell, item: item)
                }
            }
            else {
                
                section!.insert(item: message, at: 0, cellClass: STDialogOtherCell.self) { [unowned self] (cell, item) in
                    
                    self.otherCellBindingAction(cell: cell, item: item)
                }
            }
        }
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
    
    fileprivate func otherCellBindingAction(cell: UITableViewCell, item: TableSectionItem) {
        
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
            
            viewCell.userImage.reactive.tap.observeNext { [weak self] in
                
                    self?.st_router_openUserProfile(user: user)
                }
                .dispose(in: viewCell.disposeBag)
            
            if user.imageUrl.isEmpty {
                
                var defaultImage = UIImage(named: "avatar")
                defaultImage = defaultImage?.af_imageAspectScaled(toFill: viewCell.userImage.bounds.size)
                viewCell.userImage.setImage(defaultImage?.af_imageRoundedIntoCircle(), for: .normal)
            }
            else {
                
                let urlString = user.imageUrl + viewCell.userImage.queryResizeString()
                let filter = RoundedCornersFilter(radius: viewCell.userImage.bounds.size.width)
                viewCell.userImage.af_setImage(for: .normal, url: URL(string: urlString)!, filter: filter)
            }
        }
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
        
        let myUser = self.myUser
        
        if myUser.imageData != nil {
            
            if let image = UIImage(data: self.myUser.imageData!) {
                
                let userIcon = image.af_imageAspectScaled(toFill: viewCell.userImage.bounds.size)
                viewCell.userImage.setImage(userIcon.af_imageRoundedIntoCircle(), for: .normal)
            }
        }
        else {
            
            if myUser.imageUrl.isEmpty {
                
                var defaultImage = UIImage(named: "avatar")
                defaultImage = defaultImage?.af_imageAspectScaled(toFill: viewCell.userImage.bounds.size)
                viewCell.userImage.setImage(defaultImage?.af_imageRoundedIntoCircle(), for: .normal)
            }
            else {
                
                let urlString = myUser.imageUrl + viewCell.userImage.queryResizeString()
                let filter = RoundedCornersFilter(radius: viewCell.userImage.bounds.size.width)
                viewCell.userImage.af_setImage(for: .normal, url: URL(string: urlString)!, filter: filter)
            }
        }
    }
    
    fileprivate func newSection(date: Date) -> TableSection {
        
        let section = TableSection()
        section.sectionType = date
        section.header(item: date.dayMonthFormat,
                       headerClass: STDialogSectionHeader.self,
                        bindingAction: { (cell, item) in
                            
                            let header = cell as! STDialogSectionHeader
                            let date = item.item as! String
                            header.dateLabel.text = date
        })
        
        section.headerItem?.cellHeight = 30
        
        return section
    }
    
    private func reloadTableView(animation: Bool = false) {
        
        if animation {
            
            self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        }
        else {
            
            self.tableView.reloadData()
        }
        
        if self.tableView.numberOfSections == 0
            || self.tableView.numberOfRows(inSection: 0) == 0 {
            
            self.showDummyView(imageName: "empty-messages",
                               title: "dummy_chat_empty_mesages_title".localized,
                               subTitle: "dummy_chat_empty_mesages_subtitle".localized) { view in
            
                                view.backgroundColor = UIColor.white
            }
        }
        else {
            
            self.hideDummyView()
        }
    }
    
    fileprivate func loadNecessaryDataIfNeeded() {
        
        // If we have just a post id
        if self.dialog == nil {
            
            self.users.append(myUser)
            
            if let postId = self.postId, let objectType = self.objectType {
                
                self.tableView.showBusy()
                
                api.createDialog(objectId: postId, objectType: objectType)
                    .onSuccess { [weak self] dialog in
                        
                        guard let sself = self else {
                            
                            return
                        }
                        
                        sself.dialog = dialog
                        
                        // load an apponent id
                        if let userId = dialog.userIds.first(where: { $0.value != sself.myUser.id }) {
                            
                            sself.api.loadUser(transport: .websocket, userId: userId.value)
                                .onSuccess(callback: { [weak self] user in
                                    
                                    self?.tableView.hideBusy()
                                    
                                    self?.users.append(user)
                                    self?.loadMessages()
                                })
                                .onFailure(callback: { [weak self] error in
                                    
                                    self?.tableView.hideBusy()
                                })
                        }
                    }
                    .onFailure { [weak self] error in
                        
                        self?.tableView.hideBusy()
                }
            }
            
            return
        }
        
        self.loadMessages()
    }
}

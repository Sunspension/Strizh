//
//  ChatPresenter.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 12/10/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation

class ChatPresenter {
    
    private var analytics: STAnalytics {
        
        return try! AppDelegate.appSettings.dependencyContainer.resolve()
    }
    
    private var myUser: STUser {
        
        return STUser.objects(by: STUser.self).first!
    }
    
    private var api: PRemoteServerApi {
        
        return AppDelegate.appSettings.api
    }
    
    private var dialog: STDialog?
    
    private var users: [STUser] = []
    
    private var messages = Set<STMessage>()
    
    private var hasMore = false
    
    private var pageSize = 20
    
    private var sections = [GenericSection<STMessage>]()
    
    var objectType: Int?
    
    var postId: Int?
    
    var lastId: Int64?
    
    var view: ChatViewInputable?
    
    
    init(dialog: STDialog, users: [STUser]) {
        
        self.dialog = dialog
        self.users = users
    }
    
    private func loadNecessaryDataIfNeeded() {
        
        
    }
    
    private func loadMessages(dialogId: Int, pageSize: Int, lastId: Int64?, loadMore: Bool = false) {
        
        api.loadDialogMessages(dialogId: dialogId, pageSize: pageSize, lastId: lastId)
            .onSuccess { [unowned self] messages in
                
                self.onSuccessLoadMessages(messages: messages, loadMore: loadMore)
            }
            .onFailure { [unowned self] error in
                
                self.view?.hideActivityIndicator()
                self.view?.onError(error: error)
        }
    }
    
    private func onSuccessLoadMessages(messages: [STMessage], loadMore: Bool) {
        
        self.view?.hideActivityIndicator()
        self.manageLastMessageId(messages: messages, loadMore: loadMore)
        self.hasMore = messages.count == self.pageSize
        
        for message in messages {
            
            self.messages.insert(message)
        }
        
        self.createDataSource(messages)
        
        if loadMore {
            
            self.view?.updateViewAfterLoadMore()
        }
        else {
            
            self.view?.reloadTableView(animation: false)
        }
        
        // Scroll to last message
        guard self.sections.flatMap({ $0.items }).count != 0 else {
            
            return
        }
        
        let indexPath = self.indexPathOfLastMessage()
        self.view?.scrollToLastMessage(indexPath: indexPath, animated: false)
    }
    
    private func manageLastMessageId(messages: [STMessage], loadMore: Bool) {
        
        if let lastMessage = messages.last {
            
            self.lastId = lastMessage.id
            
            guard let dialog = self.dialog else {
                
                return
            }
            
            if !loadMore && dialog.unreadMessageCount != 0 {
                
                if let firstMessage = messages.first {
                    
                    let lastMessageId = firstMessage.userId == self.myUser.id ?
                        firstMessage.lastMessageId : firstMessage.id
                    self.notifyMessagesRead(lastReadMessage: lastMessageId)
                }
            }
        }
    }
    
    private func notifyMessagesRead(lastReadMessage: Int64?) {
        
        api.notifyMessagesRead(dialogId: self.dialog!.id, lastMessageId: lastReadMessage)
            .onSuccess { dialog in
                
                let name = NSNotification.Name(kPostUpdateDialogNotification)
                NotificationCenter.default.post(name: name, object: dialog)
        }
    }
    
    private func indexPathOfLastMessage() -> IndexPath {
        
        let section = self.sections.last!
        let item = section.items.last!
        let itemIndex = section.items.index(of: item)!
        let sectionIndex = self.sections.index(of: section)
        
        return IndexPath(item: itemIndex, section: sectionIndex!)
    }
    
    private func createDataSource(_ messages: [STMessage]) {
        
        guard messages.count > 0 else {
            
            return
        }
        
        var section = self.section(for: messages[0])
        
        for message in messages.sorted(by: { $0.id > $1.id }) {
            
            if section.title != message.createdAt.defaultFormat {
                
                section = self.section(for: message)
            }
            
            section.add(message)
        }
    }
    
    private func section(for message: STMessage) -> GenericSection<STMessage> {
        
        var section = self.section(by: message.createdAt)
        
        if section == nil {
            
            section = GenericSection<STMessage>(title: message.createdAt.defaultFormat)
            self.sections.insert(section!, at: 0)
        }
        
        return section!
    }
    
    private func section(by date: Date) -> GenericSection<STMessage>? {
        
        let section = self.sections.first(where: { section -> Bool in
            
            if let sectionDate = section.type as? Date {
                
                return sectionDate.isTheSameDay(date: date)
            }
            
            return false
        })
        
        return section
    }
}


extension ChatPresenter: ChatViewOutputable {
    
    func showBusy() {
        
    }
    
    func popAction() {
        
        guard let dialog = self.dialog else {
            
            return
        }
        
        self.analytics.endTimeEvent(eventName: st_eBackToDialogList,
                                    params: ["post_id" : dialog.postId, "dialog_id" : dialog.id])
    }
    
    func viewWillAppear() {
        
        self.analytics.logEvent(eventName: st_eDialog, timed: true)
    }
    
    func viewWillDisappear() {
        
        self.analytics.endTimeEvent(eventName: st_eDialog)
    }
    
    func viewDidLoad() {
        
        // TODO load nesessary data if needed
        guard let dialog = self.dialog else {
            
            return
        }
        
        self.loadMessages(dialogId: dialog.id, pageSize: self.pageSize, lastId: self.lastId)
    }
}

//
//  ChatInteractor.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 12/10/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation
import BrightFutures

protocol ChatInteractorInputable {
    
    func loadMessages(dialogId: Int, pageSize: Int, lastId: Int64?) -> Future<[STMessage], STError>
}

class ChatInteractor {
    
    private var api: PRemoteServerApi {
        
        return AppDelegate.appSettings.api
    }
    
    var messages = [STMessage]()
    
    var loadingStatus = STLoadingStatusEnum.idle
    
    public func loadMessages(dialogId: Int, pageSize: Int, lastId: Int64?) -> Future<[STMessage], STError> {
        
        loadingStatus = .loading
        
        api.loadDialogMessages(dialogId: dialogId, pageSize: pageSize, lastId: lastId)
            .onSuccess { [unowned self] messages in
        
                self.loadingStatus = .loaded
                self.messages.append(contentsOf: messages)
            }
            .onFailure { error in
            
                self.loadingStatus = .failed
            }
    }
    
    private func loadNecessaryDataIfNeeded() {
        
        // If we have just a post id
        if self.dialog == nil {
            
            self.users.append(myUser)
            
            if let postId = self.postId, let objectType = self.objectType {
                
                view?.showActivityIndicator()
                
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
                                    
                                    self?.view?.hideActivityIndicator()
                                    self?.users.append(user)
                                    self?.loadMessages()
                                })
                                .onFailure(callback: { [weak self] error in
                                    
                                    self?.view?.hideActivityIndicator()
                                })
                        }
                    }
                    .onFailure { [weak self] error in
                        
                        self?.view?.hideActivityIndicator()
                }
            }
            
            return
        }
        
        self.loadMessages()
    }
}

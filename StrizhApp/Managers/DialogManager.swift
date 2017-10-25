//
//  DialogManager.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 13/10/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation
import BrightFutures

struct DialogManager {
    
    private var api: PRemoteServerApi {
        
        return AppDelegate.appSettings.api
    }
    
    func createDialog(objectId: Int, objectType: Int) -> Future<STDialog, STError> {
        
        api.createDialog(objectId: objectId, objectType: objectType)
            .onSuccess { dialog in
                
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
            .onFailure { error in
                
                self?.view?.hideActivityIndicator()
        }
    }
}

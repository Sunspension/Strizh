//
//  STError.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 21/01/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit

enum STError: Error {
    
    case favoriteFailure
    
    case archiveFailure
    
    case loadContactsFailure
    
    case loadFeedFailure
    
    case loadFeedByUserIdFailure
    
    case createPostError
    
    case loadDialogsError
    
    case loadPostError
    
    case loadDialogError
    
    case loadMessagesError
    
    case sendMessageError
    
    case notifyMessagesReadError
    
    case createDialogError
    
    case loadMessageError
    
    case updateNotificationSettingsError
    
    case anyError(error: Error)
    
    
    var localizedDescription: String {
        
        switch self {
            
        case .anyError(let error):
            
            return error.localizedDescription
            
        case .favoriteFailure:
            
            return "Error has occurred when was trying to add to favorite or remove from favorite"
            
        case .loadContactsFailure:
            
            return "Error has occurred when was trying to load contacts"
            
        case .loadFeedFailure:
            
            return "Error has occurred when was trying to load feed"
            
        case .loadFeedByUserIdFailure:
            
            return "Error has occurred when was trying to load feed by user id"
            
        case .archiveFailure:
            
            return "Error has occurred when was trying to archive a post"
            
        case .createPostError:
            
            return "Error has occurred when was trying to create a post"
            
        case .loadDialogsError:
            
            return "Error has occurred when was trying to load dialogs"
            
        case .loadDialogError:
            
            return "Error has occurred when was trying to load a dialog"
            
        case .loadPostError:
            
            return "Error has occurred when was trying to load a post"
            
        case .loadMessagesError:
            
            return "Error has occurred when was trying to load dialog messages"
            
        case .sendMessageError:
            
            return "Error has occurred when was trying to send dialog messages"
            
        case .notifyMessagesReadError:
            
            return "Error has occurred when was trying to notify about read messages"
            
        case .createDialogError:
            
            return "Error has occurred when was trying to create a dialog"
            
        case .loadMessageError:
            
            return "Error has occurred when was trying to load a message"
            
        case .updateNotificationSettingsError:
            
            return "Error has occurred when was trying to update user notification settings"
        }
    }
}

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
    
    case uploadContactsFailure
    
    case loadFeedFailure
    
    case updateUserFailure
    
    case loadUserFalure
    
    case loadFeedByUserIdFailure
    
    case createPostError
    
    case updatePostError
    
    case loadDialogsError
    
    case loadPostError
    
    case deletePostFailure
    
    case loadDialogError
    
    case loadMessagesError
    
    case sendMessageError
    
    case notifyMessagesReadError
    
    case createDialogError
    
    case loadMessageError
    
    case updateNotificationSettingsError
    
    case anyError(error: Error)
    
    case error(message: String)
    
    
    var localizedDescription: String {
        
        switch self {
            
        case .anyError(let error):
            
            return error.localizedDescription
            
        case .favoriteFailure:
            
            return "Error has occurred when was trying to add to favorite or remove from favorite"
            
        case .loadUserFalure:
            
            return "Error has occurred when was trying to load user"
            
        case .updateUserFailure:
            
            return "Error has occurred when was trying to update user information"
            
        case .uploadContactsFailure:
            
            return "Error has occurred when was trying to upload contacts"
            
        case .loadContactsFailure:
            
            return "Error has occurred when was trying to load contacts"
            
        case .loadFeedFailure:
            
            return "Error has occurred when was trying to load feed"
            
        case .loadFeedByUserIdFailure:
            
            return "Error has occurred when was trying to load feed by user id"
            
        case .deletePostFailure:
            
            return "Error has occurred when was trying to delete post"
            
        case .archiveFailure:
            
            return "Error has occurred when was trying to archive post"
            
        case .createPostError:
            
            return "Error has occurred when was trying to create post"
            
        case .updatePostError:
            
            return "Error has occurred when was trying to update post"
            
        case .loadDialogsError:
            
            return "Error has occurred when was trying to load dialogs"
            
        case .loadDialogError:
            
            return "Error has occurred when was trying to load dialog"
            
        case .loadPostError:
            
            return "Error has occurred when was trying to load post"
            
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
            
        case .error(let message):
            
            return message
        }
    }
}

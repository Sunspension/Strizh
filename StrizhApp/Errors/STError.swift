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
    
    case createPostError
    
    case loadDialogsError
    
    case loadMessagesError
    
    case sendMessageError
    
    case notifyMessagesReadError
    
    case anyError(error: Error)
    
    
    var localizedDescription: String {
        
        switch self {
            
        case .anyError(let error):
            
            return error.localizedDescription
            
        case .favoriteFailure:
            
            return "Error has occurred when was trying to add to favorite or remove from favorite"
            
        case .loadContactsFailure:
            
            return "Error has occurred when was trying to load contacts"
            
        case .archiveFailure:
            
            return "Error has occurred when was trying to archive a post"
            
        case .createPostError:
            
            return "Error has occurred when was trying to create a post"
            
        case .loadDialogsError:
            
            return "Error has occurred when was trying to load dialogs"
            
        case .loadMessagesError:
            
            return "Error has occurred when was trying to load dialog messages"
            
        case .sendMessageError:
            
            return "Error has occurred when was trying to send dialog messages"
            
        case .notifyMessagesReadError:
            
            return "Error has occurred when was trying to notify about read messages"
        }
    }
}

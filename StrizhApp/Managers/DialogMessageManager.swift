//
//  DialogMessageManager.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 12/10/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation

struct DialogMessageManager {
    
    private var loadingStatus = STLoadingStatusEnum.idle
    
    private var api: PRemoteServerApi {
        
        return AppDelegate.appSettings.api
    }
    
    
    
}

//
//  AppSettings.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 23/01/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit

struct AppSettings {

    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
    
    var db: PDataBase
    
    var api: PRemoteServerApi
    
    
    init(dataBase: PDataBase, serverApi: PRemoteServerApi) {
        
        self.db = dataBase
        self.api = serverApi
    }
}

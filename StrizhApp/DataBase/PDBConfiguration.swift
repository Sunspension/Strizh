//
//  PDataBase.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 21/01/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import RealmSwift
import ObjectMapper

protocol PDBConfiguration {
    
    func configure()
    
    func onLogout()
}

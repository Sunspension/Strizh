//
//  RealmDouble.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 19/03/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import RealmSwift

class RealmDouble: Object, RealmCustomObject {
    
    typealias ObjectType = Double
    
    var value = 0.0
}

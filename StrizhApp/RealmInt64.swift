//
//  RealmDouble.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 19/03/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import RealmSwift

class RealmInt64: Object, RealmCustomObject {
    
    typealias ObjectType = Int64
    
    @objc dynamic var value: Int64 = 0
}

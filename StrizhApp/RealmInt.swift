//
//  IntObject.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 20/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import RealmSwift

class RealmInt: Object, RealmCustomObject {
    
    typealias ObjectType = Int
    
    @objc dynamic var value = 0
}

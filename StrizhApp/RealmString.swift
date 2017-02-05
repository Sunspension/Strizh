//
//  StringObject.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 20/08/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import RealmSwift

class RealmString: Object, RealmCustomObject {
    
    typealias ObjectType = String
    
    var value = ""
}

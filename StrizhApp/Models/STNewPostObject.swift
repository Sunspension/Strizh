//
//  STNewPostObject.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 02/03/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation

struct STNewPostObject {
    
    var type = 0
    
    var title = ""
    
    var details = ""
    
    var fromDate: Date?
    
    var tillDate: Date?
    
    var price = ""
    
    var priceDescription = ""
    
    var profitDescription = ""
    
    var imageIds: [Int64]?
    
    var locationIds: [Int]?
    
    var userIds = [Int]()
}

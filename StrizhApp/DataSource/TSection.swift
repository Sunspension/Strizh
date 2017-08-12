//
//  TSection.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 09/08/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation

final class TSection: Equatable {
    
    var id = UUID()
    
    var title: String?
    
    private(set) var items = [TItem]()
    
    var selectedItems = [TItem]()
    
    var type: Any?
    
    public static func == (lhs: TSection, rhs: TSection) -> Bool {
        
        return lhs.id == rhs.id
    }
    
    init(title: String? = "") {
        
        self.title = title;
    }
    
    func add(model: Any) {
        
        self.items.append(TItem(model: model))
    }
    
    func add(models: [Any]) {
        
        self.items.append(contentsOf: models.map({ TItem(model: $0) }))
    }
    
    func insert(model: Any, at: Int) {
        
        let item = TItem(model: model)
        self.items.insert(item, at: at)
    }
}

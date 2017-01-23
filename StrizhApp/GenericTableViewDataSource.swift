//
//  GenericTableViewDataSource.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 10/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

class GenericTableViewDataSource<TTableViewCell: UITableViewCell, TTableItem: Any>: NSObject, UITableViewDataSource {

    var sections: [GenericCollectionSection<TTableItem>] = []
    
    var bindingAction: (_ cell: TTableViewCell, _ item: GenericCollectionSectionItem<TTableItem>) -> Void
    
    var reusableIdentifierOrNibName: String?
    
    init(reusableIdentifierOrNibName: String? = nil, bindingAction: @escaping (_ cell: TTableViewCell, _ item: GenericCollectionSectionItem<TTableItem>) -> Void) {
        
        self.bindingAction = bindingAction
        self.reusableIdentifierOrNibName = reusableIdentifierOrNibName
        
        super.init()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.sections[section].items.count 
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return self.sections.count 
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = self.sections[(indexPath as NSIndexPath).section].items[(indexPath as NSIndexPath).row]
        item.indexPath = indexPath
        
        if let identifier = self.reusableIdentifierOrNibName {
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? TTableViewCell {
                
                self.bindingAction(cell, item)
                
                return cell
            }
            
            if let cell = Bundle.main.loadNibNamed(self.reusableIdentifierOrNibName!, owner: self, options: nil)!.last as? TTableViewCell {
                
                self.bindingAction(cell, item)
                return cell
            }
        }
        
        let cell =  UITableViewCell() as! TTableViewCell
        self.bindingAction(cell, item)
        
        return cell;
    }
}

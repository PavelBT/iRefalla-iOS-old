//
//  ParseTableViewProtocol.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 18/04/20.
//  Copyright © 2020 Pavel Balderrama. All rights reserved.
//

import Foundation

protocol ParseTableViewProtocol: UITableViewController  {
    var array: [ParseManager]? {get set}
    var arrayFiltred: [ParseManager]? {get set}
    var filter: [queryParams]? {get set}
    func loadData<T: ParseManager>(clase: T.Type, page: Int)
        
}

extension ParseTableViewProtocol  where Self: UITableViewDataSource  {
    
    func loadData<T: ParseManager>(clase: T.Type, page: Int = 0) {
        T.getFilter(filter: self.filter) { (data) in
            self.array = data
            self.tableView.reloadData()
        }
    }
}

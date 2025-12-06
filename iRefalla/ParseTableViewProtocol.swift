//
//  ParseTableViewProtocol.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 18/04/20.
//  Copyright © 2020 Pavel Balderrama. All rights reserved.
//

import Foundation

protocol ParseTableViewProtocol: AnyObject {
    var tableView: UITableView! { get }
    var array: [ParseManager]? {get set}
    var filteredArray: [ParseManager]? {get set}
    var filter: [queryParams]? {get set}
    func loadData<T: ParseManager>(type: T.Type, page: Int)
}

extension ParseTableViewProtocol  where Self: UIViewController  {
    
    func loadData<T: ParseManager>(type: T.Type, page: Int = 0) {
        T.getFilter(filter: self.filter) { [weak self] (data) in
            guard let self = self else { return }
            self.array = data
            self.tableView.reloadData()
        }
    }
    
    func loadDataAsync<T: ParseManager>(type: T.Type, page: Int = 0) {
        Task {
            do {
                let data = try await T.getFilter(limit: 100, page: page, filter: self.filter)
                await MainActor.run {
                    self.array = data
                    self.tableView.reloadData()
                }
            } catch {
                print("Error loading data async: \(error)")
            }
        }
    }
}

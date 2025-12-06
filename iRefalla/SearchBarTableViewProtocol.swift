//
//  SearchBarTableViewProtocol.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 18/04/20.
//  Copyright © 2020 Pavel Balderrama. All rights reserved.
//

import Foundation

protocol SearchBarTableViewProtocol: UISearchBarDelegate, UISearchResultsUpdating {
    var searchController: UISearchController {get}
    var array: [ParseManager]? {get set}
    var filteredArray: [ParseManager]? {get set}
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int)
    func updateSearchResults(for searchController: UISearchController)
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    func filterContentForSearchText(searchBarText: String, scope: String)
}

extension SearchBarTableViewProtocol where Self: UIViewController {
    
    var searchBarActive: Bool {
        return searchController.isActive
    }
    
    func selectedRow<T>(index: Int) -> T? {
        if searchBarActive {
            return self.filteredArray?[index] as? T
        } else {
            return self.array?[index] as? T
        }
    }
    
    func loadSearchBar(placeholder: String, scopeTitles: [String]? = nil, hide:Bool = true) {
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = placeholder
        searchController.searchBar.searchBarStyle =  .default
        searchController.searchBar.scopeButtonTitles = scopeTitles
        searchController.extendedLayoutIncludesOpaqueBars = false
        
        if #available(iOS 11.0, *) {
            self.navigationItem.searchController = searchController
            self.navigationItem.hidesSearchBarWhenScrolling = hide
        } else {
            // Fallback for older iOS versions if needed, or just ignore
             print("searchBar in table view header not supported in this protocol extension directly without tableview access")
        }
    }
}

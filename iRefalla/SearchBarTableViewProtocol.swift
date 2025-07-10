//
//  SearchBarTableViewProtocol.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 18/04/20.
//  Copyright © 2020 Pavel Balderrama. All rights reserved.
//

import Foundation

protocol SearchBarTableViewProtocol:UITableViewController, UISearchBarDelegate, UISearchResultsUpdating {
    var searchController: UISearchController {get}
    var array: [ParseManager]? {get set}
    var arrayFiltred: [ParseManager]? {get set}
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int)
    func updateSearchResults(for searchController: UISearchController)
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    func filterContentForSearchText(searchBarText: String, scope: String)
}

extension SearchBarTableViewProtocol where Self: UITableViewController {
    
    var searchBarActive: Bool {
        return searchController.isActive
    }
    
    func selectedRow<T>(index: Int) -> T {
        var row: T!
        if searchBarActive {
            row = self.array?[index] as? T
        } else {
            row = self.array?[index] as? T
        }
        return row
    }
    
    func loadSeachBar(placeholder: String, scopeTitles: [String]? = nil, hide:Bool = true) {
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = placeholder
        searchController.searchBar.searchBarStyle =  .default
        searchController.searchBar.scopeButtonTitles = scopeTitles
        searchController.extendedLayoutIncludesOpaqueBars = false
        
//        // CONFIGURAR COLORES A BLANCO
//        if navigationController?.navigationBar.barStyle != UIBarStyle.default {
//            searchController.searchBar.tintColor = UIColor.white
//            if let textfield = searchController.searchBar.value(forKey: "searchField") as? UITextField {
//                if let backgroundview = textfield.subviews.first {
//                    // Background color
//                    backgroundview.backgroundColor = UIColor.gray
//                    // Rounded corner
//                    backgroundview.layer.cornerRadius = 10;
//                    backgroundview.clipsToBounds = true;
//                }
//            }
//        }
        
        if #available(iOS 11.0, *) {
            self.navigationItem.searchController = searchController
            self.navigationItem.hidesSearchBarWhenScrolling = hide
        } else {
            tableView.tableHeaderView = searchController.searchBar
            print("searcbar en table view")
        }
        
        //OCULTAR LA BARRA DE BUSQUEDA
        if hide {
            var newBounds : CGRect? = self.tableView.bounds
            newBounds?.origin.y = 0
            newBounds?.origin.y += searchController.searchBar.bounds.height
            self.tableView.bounds = newBounds!
            
        }
    }
}

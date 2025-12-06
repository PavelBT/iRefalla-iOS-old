//
//  TableViewProtocol.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 26/09/18.
//  Copyright © 2018 Pavel Balderrama. All rights reserved.
//

import Foundation

protocol TableViewProtocol  {
    func configure() -> ConfigTable
    func filterContentForSearchText(searchBarText: String, scope: String?)
}

struct ConfigTable {
    var title: String?
    var placeholder: String = "placeholder"
    var preferLargeTitles = true
    var scopeTitles: [String]? = nil
    var searchBarHidden: Bool = true
    var searchBarEnable: Bool = true
    var forceCancelButton: Bool = false
}

class TableViewSearchBar: UITableViewController {
    var searchController = UISearchController(searchResultsController: nil)
    var delegate: TableViewProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = configTable.title
        self.navigationController?.navigationBar.prefersLargeTitles = configTable.preferLargeTitles
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancelar", style: .plain, target: self, action: #selector(dismissView))
        
        if configTable.searchBarEnable {
             loadSearchBar()
        }

    }
   
    @objc func dismissView () {
        dismiss(animated: true, completion: nil)
    }

}


extension TableViewSearchBar: UISearchBarDelegate, UISearchResultsUpdating  {
    
    var configTable: ConfigTable {
        return delegate?.configure() ?? ConfigTable()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles?[searchBar.selectedScopeButtonIndex]
        delegate?.filterContentForSearchText(searchBarText: searchController.searchBar.text!, scope: scope)
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        delegate?.filterContentForSearchText(searchBarText: searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchController.isActive = false
    }
    
    
    @objc var searchBarActive: Bool {
        return searchController.isActive
    }
    
    // handler functions
    
    func loadSearchBar() {
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        searchController.searchBar.placeholder = self.configTable.placeholder
        searchController.searchBar.searchBarStyle =  .default
        searchController.searchBar.scopeButtonTitles = self.configTable.scopeTitles
        searchController.searchBar.showsBookmarkButton = true
        searchController.searchBar.showsSearchResultsButton = true
        searchController.obscuresBackgroundDuringPresentation = false
        
        if #available(iOS 11.0, *) {
            self.navigationItem.searchController = searchController
            self.navigationItem.hidesSearchBarWhenScrolling = self.configTable.searchBarHidden
        } else {
            self.tableView.tableHeaderView = searchController.searchBar
        }
        
        definesPresentationContext = true
        
        //OCULTAR LA BARRA DE BUSQUEDA
        if self.configTable.searchBarHidden {
            var newBounds : CGRect? = self.tableView.bounds
            newBounds?.origin.y = 0
            newBounds?.origin.y += searchController.searchBar.bounds.height
            self.tableView.bounds = newBounds!
            
        }
    }
}

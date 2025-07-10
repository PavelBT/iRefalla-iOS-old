//
//  CausasTableViewController.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 04/05/17.
//  Copyright © 2017 Pavel Balderrama. All rights reserved.
//

import UIKit

class CausasTableViewController: UITableViewController {

    fileprivate var causas: [Causa]?
    fileprivate var causasFiltred: [Causa]?
    fileprivate let cellID = "causaCell"
    fileprivate var searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancelar", style: .plain, target: self, action: #selector(dismissView))
        tableView.contentInset = UIEdgeInsets.init(top: 20, left: 0, bottom: 0, right: 0)
        
        if let causa = Causa.getLocalLabel(label: newItemsLabel).first {
            causa.unpinLabel(label: newItemsLabel)
        }
        
        loadData()
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchBarLoad(searchController: searchController, placeholder: "Clave, Descripcion", ScopeTitles: ["Todo", "D", "R", "Q", "W"], hide: false)
    }

    private func loadData() {
        Causa.getAll(limit: 500) { data in
            self.causas = data
            GlobalMainQueue.async {
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func dismissView() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if searchBarActive {
            return causasFiltred?.count ?? 0
        } else {
            return causas?.count ?? 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let index = indexPath.row
        let row = selectedCausa(index: index)
        
        cell.textLabel?.text = row.nombre
        cell.detailTextLabel?.text = row.clave

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        let causa = causas?[index]
        causa?.pinLabel(label: newItemsLabel)
        dismissView()
    }
}


extension CausasTableViewController: UISearchBarDelegate, UISearchResultsUpdating {
    
    var searchBarActive: Bool {
        return searchController.isActive
    }
    
    func selectedCausa(index: Int) -> Causa {
        var row: Causa!
        if searchBarActive {
            row = causasFiltred?[index]
        } else {
            row = causas?[index]
        }
        return row
    }
    
    func filterContentForSearchText(searchBarText: String, scope: String = "Todo") {
        causasFiltred = causas?.filter({ (causa) -> Bool in
            let text = searchBarText.lowercased()
            let id = causa.clave?.lowercased() ?? ""
            let nombre = causa.nombre?.lowercased() ?? ""
            let scopeMatch: Bool = (scope == "Todo" || id.contains(scope.lowercased()))

            return scopeMatch && (nombre.contains(text) || id.contains(text) || text == "")
        })
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBarText: searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchBarText: searchController.searchBar.text!, scope: scope)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchController.isActive = false
    }
    
}

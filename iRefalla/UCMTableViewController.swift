//
//  UCMTableViewController.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 27/02/18.
//  Copyright © 2018 Pavel Balderrama. All rights reserved.
//

import UIKit
import MRProgress

fileprivate let cellID = "UCMCell"

class UCMTableViewController: UITableViewController {
    
    fileprivate var searchController = UISearchController(searchResultsController: nil)
    fileprivate var ucmEventos: [UcmSOE]?
    fileprivate var ucmEventosFiltred: [UcmSOE]?
    fileprivate var page: Int? = 0
    fileprivate var filterParams: [queryParams]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "SOE UCM"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancelar", style: .plain, target: self, action: #selector(dismissView))
        
        // LOAD SEARCHBAR
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        
        var scopeTitles = ["Todo", "CB & PR"]
        tipoEvento.allValues.forEach {scopeTitles.append($0.rawValue)}
        searchBarLoad(searchController: searchController, placeholder: "Subestacion, Circuito, Restaurador", ScopeTitles: scopeTitles)
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        } else {
            // Fallback on earlier versions
        }
        
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableView.automaticDimension
        
        loadData()
    }

    @objc func dismissView () {
        dismiss(animated: true, completion: nil)
    }
    
   
    private func loadData(page: Int = 0) {
        loadActivityIndicator(title: "Cargando")
        UcmSOE.getFilter(page: page, filter: self.filterParams) { (data) in
            if let data = data, data.count > 0 {
                if page == 0 {
                    self.ucmEventos =  data
                } else {
                    self.ucmEventos = self.ucmEventos! + data
                }
                GlobalMainQueue.async {
                    self.dismissActivityIndicator()
                    self.tableView.reloadData()
                }
            } else {
                self.page = nil // se acabaron las filas
                self.dismissActivityIndicator()
            }
        }
    }
    
    @IBAction func reloadData(_ sender: Any) {
        filterParams = nil
        page = 1
        loadData()
    }
    
   
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if searchBarActive {
            return self.ucmEventosFiltred?.count ?? 0
        } else {
            return self.ucmEventos?.count ?? 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? UCMTableViewCell
        
        let row = selectedEvent(index: indexPath.row)
        cell?.ucmEvento = row
        if indexPath.row == self.ucmEventos!.count-1, self.page != nil {
            self.page! += 1
            loadData(page: self.page!)
        }
    
        return cell!
    }
    
    @available(iOS 11.0, *)
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal, title: nil) { (action, view, sucess) in
            let row = self.selectedEvent(index: indexPath.row)
            self.filterParams = [queryParams("path1", row.path1, .equal), queryParams("path3", row.path3, .equal)]
            self.page = 0
            self.loadData()
            
        }
        action.image = #imageLiteral(resourceName: "filtroFill")
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let filterAction = UITableViewRowAction(style: .default, title: "Filtrar") { (action, index) in
            
        }
        return [filterAction]
    }
}

extension UCMTableViewController: UISearchBarDelegate, UISearchResultsUpdating {
    
    var searchBarActive: Bool {
        return searchController.isActive
    }
    
    func selectedEvent(index: Int) -> UcmSOE {
        var row: UcmSOE!
        if searchBarActive {
            row = ucmEventosFiltred?[index]
        } else {
            row = ucmEventos?[index]
        }
        return row
    }
    
    func filterContentForSearchText(searchBarText: String, scope: String) {
        ucmEventosFiltred = ucmEventos?.filter({ (evento) -> Bool in
            let text = searchBarText.lowercased()
            let path1 = evento.path1?.lowercased() ?? ""
            let path3 = evento.path3?.lowercased() ?? ""
            let path4 = evento.path4?.lowercased() ?? ""
            var scopeMatch: Bool = false
            if scope == "CB & PR" {
                scopeMatch = evento.tipo.rawValue == "CB" || evento.tipo.rawValue == "PR"
            } else {
                 scopeMatch = scope == "Todo" || scope == evento.tipo.rawValue
            }
            return scopeMatch && ((path1.contains(text) || path3.contains(text) || path4.contains(text)) || text == "")
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


//
//  UCMEventsTableViewController.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 03/09/18.
//  Copyright © 2018 Pavel Balderrama. All rights reserved.
//

import Foundation

fileprivate let cellID = "UCMCell"

class UCMEventsTableViewController: UITableViewController {
    
    fileprivate var searchController = UISearchController(searchResultsController: nil)
    fileprivate var ucmEventos: [UcmEvent]?
    fileprivate var ucmEventosFiltred: [UcmEvent]?
    fileprivate var page: Int? = 0
    fileprivate var filterParams: [queryParams]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Eventos UCM"
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
        UcmEvent.getFilter(page: page, filter: self.filterParams) { (data) in
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
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? UCMEventTableViewCell
        
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
            self.filterParams = [queryParams("subestacion", row.subestacion, .equal), queryParams("dispositivo", row.equipo, .contains)]
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

extension UCMEventsTableViewController: UISearchBarDelegate, UISearchResultsUpdating {
    
    var searchBarActive: Bool {
        return searchController.isActive
    }
    
    func selectedEvent(index: Int) -> UcmEvent {
        var row: UcmEvent!
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
            let subestacion = evento.subestacion.lowercased()
            let circuito = evento.equipo.lowercased()
            let ramal = evento.ramal?.lowercased() ?? ""
            var scopeMatch: Bool = false
            scopeMatch = scope == "Todo"
            return scopeMatch && ((subestacion.contains(text) || circuito.contains(text) || ramal.contains(text)) || text == "")
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

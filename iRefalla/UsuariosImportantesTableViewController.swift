//
//  UsuariosImportantesTableViewController.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 15/04/20.
//  Copyright © 2020 Pavel Balderrama. All rights reserved.
//

import UIKit
import MapKit

fileprivate let cellID = "uicell"

class UsuariosImportantesTableViewController: UITableViewController, ParseTableViewProtocol {
    
    var array: [ParseManager]?
    var arrayFiltred: [ParseManager]?
    var filter: [queryParams]?
    var searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Usuarios Importantes"
        
        if #available(iOS 13.0, *) {
        } else {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancelar", style: .plain, target: self, action: #selector(dismissView))
        }
        
        loadData(clase: UsuarioImportante.self, page: 0)
        loadSeachBar(placeholder: "Nombre, Giro", scopeTitles: ["Hospital", "Agua"])
        
        tableView.estimatedRowHeight = 180.0
        tableView.rowHeight = UITableView.automaticDimension
        
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
            return arrayFiltred?.count ?? 0
        } else {
            return array?.count ?? 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! UsuariosImpTableViewCell
        let row = selectedRow(index: indexPath.row) as UsuarioImportante
        cell.usuarioImp = row
        cell.delegate = self
        // Configure the cell...

        return cell
    }

}


extension UsuariosImportantesTableViewController: SearchBarTableViewProtocol {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchBarText: searchController.searchBar.text!, scope: parseScope(scope: scope))
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        let scope = searchBar.scopeButtonTitles![selectedScope]
//        searchBar.endEditing(true)
        filterContentForSearchText(searchBarText: searchBar.text!, scope: parseScope(scope: scope))
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchController.isActive = false
    }
    
    private func parseScope(scope: String) -> String {
        switch scope {
        case "Hospital":
            return "HOSPITAL"
        case "Agua":
            return "SERVICIO DE AGUA POTABLE"
        default:
            return "Todo"
        }
    }
    
    func filterContentForSearchText(searchBarText: String, scope: String) {
        if searchBarText != "" && searchBarText != " " {
            arrayFiltred = array?.filter({ (r) -> Bool in
                let row = r as! UsuarioImportante
                let nombre = row.nombre.lowercased()
                let giro = row.giro.lowercased()
                let scopeAssert = (scope == "Todo") || (scope.lowercased() == giro)
                return scopeAssert && (nombre.contains(searchBarText.lowercased()) || giro.contains(searchBarText.lowercased()))
            })
            self.tableView.reloadData()
        }
    }
}

extension UsuariosImportantesTableViewController: MapButtonDelegate {
    func mapButtonClick(annotation: MKAnnotation) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapViewVC") as! MapTilesViewController
        vc.annotation = annotation
        let navcon = UINavigationController(rootViewController: vc)
        self.present(navcon, animated: false, completion: nil)
    }
    
}

//
//  LineasATTableViewController.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 27/01/21.
//  Copyright © 2021 Pavel Balderrama. All rights reserved.
//

import UIKit

class LineasATTableViewController: TableViewSearchBar {

    var lineas: [LineaAT]?
    var lineasFiltred: [LineaAT]?
    var eventoMayor: EventoMayor?
    
    override func viewDidLoad() {
        delegate = self //delegate TableViewProtocol
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        loadData()
    }
    
    private func loadData() {
        LineaAT.getAll() { (lineas) in
            self.lineas = lineas
            GlobalMainQueue.async {
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if searchBarActive {
            return lineasFiltred?.count ?? 0
        } else {
            return lineas?.count ?? 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let linea = selectedRow(index:indexPath.row)
        cell.textLabel?.text = "\(linea.clave) - \(linea.nombre)"
        cell.detailTextLabel?.text = linea._detalle
        return cell

    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let eventoMayor = eventoMayor {
            let row = selectedRow(index: indexPath.row)
            eventoMayor.addUniqueObject(row, forKey: "lineas")
            eventoMayor.saveEventually()
            self.searchController.isActive = false
            self.dismiss(animated: false, completion: nil)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension LineasATTableViewController: TableViewProtocol {
    
    func configure() -> ConfigTable {
        return ConfigTable(title: "Lineas", placeholder: "clave linea", scopeTitles: nil, searchBarHidden: true )
    }
    
    func selectedRow(index: Int) -> LineaAT {
        var row: LineaAT!
        if searchBarActive {
            row = lineasFiltred?[index]
        } else {
            row = lineas?[index]
        }
        return row
    }
    
    func filterContentForSearchText(searchBarText: String, scope: String? = "ALL") {
        lineasFiltred = lineas?.filter {
//            let zona = $0.zona.lowercased()
            let clave = $0.clave.lowercased()
            return searchBarText == "" || clave.contains(searchBarText.lowercased())
        }
        tableView.reloadData()
    }

}

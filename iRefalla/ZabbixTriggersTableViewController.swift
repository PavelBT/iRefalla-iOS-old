//
//  ZabbixTriggersTableViewController.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 30/11/18.
//  Copyright © 2018 Pavel Balderrama. All rights reserved.
//

import Foundation

private let cellID = "cell"

class ZabbixTriggersTableViewController: UITableViewController {
    
    var host: Host?
    var triggers: [Trigger]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = host?.name
        
        loadData()
    }
    
    private func loadData() {
        var filter:[String : Any]?
        if let hostID = host?.hostid {
           filter = ["hostids": hostID, "filter": ["value": 1]]
        } else {
            filter = ["filter": ["value": 1]]
        }
        
        Trigger.getData(filter: filter, limit: 100) { (results) in
            self.triggers = results
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
        return triggers?.count ?? 0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let row = self.triggers?[indexPath.row]
        
        let prioridad = row?.priority ?? ""
        let fecha = row?._fecha.toStringFormatter ?? ""
        let host = self.host == nil ? ((row?.hosts?.first?.name ?? "") + " - ") : ""
        cell.textLabel?.text = host + (row?.description ?? "")
        cell.detailTextLabel?.text =  fecha + " | prioridad: " + prioridad
        cell.imageView?.image = row?.priority == "4" ? #imageLiteral(resourceName: "alarmaIcon.png") : #imageLiteral(resourceName: "alertIcon.png")
        
        return cell
    }
    
}

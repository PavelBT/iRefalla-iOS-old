//
//  ZabbixGroupsTableViewController.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 30/11/18.
//  Copyright © 2018 Pavel Balderrama. All rights reserved.
//

import UIKit

private let cellID = "cell"

class ZabbixGroupsTableViewController: UITableViewController {

    var groups: [HostGroup]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Grupos"
        
        
        loadData()
    }

    private func loadData() {
        HostGroup.getData { (results) in
            self.groups = results
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
        return groups?.count ?? 0
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let row = groups?[indexPath.row]
        
        cell.textLabel?.text = row?.name
        cell.detailTextLabel?.text = row?.hosts

        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ZGrupoToZHosts" {
            let index = tableView.indexPathForSelectedRow?.row
            let group = groups?[index!]
            let controller = segue.destination as? ZabbixHostsTableViewController
            controller?.grupo = group
        }
    }
}

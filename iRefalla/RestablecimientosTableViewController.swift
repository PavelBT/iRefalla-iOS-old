//
//  RestablecimientosTableViewController.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 01/11/18.
//  Copyright © 2018 Pavel Balderrama. All rights reserved.
//

import UIKit

fileprivate let cellID = "restablecimientoCell"

class RestablecimientosTableViewController: UITableViewController {

    var restablecimientos: [Restablecimiento]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancelar", style: .plain, target: self, action: #selector(dismissView))
        
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableView.automaticDimension
        
    }

    @objc func dismissView () {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return restablecimientos?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? RestablecimientoTableViewCell
        
        let row = restablecimientos?[indexPath.row]
        cell?.restablecimiento = row
        
        return cell!
    }


}

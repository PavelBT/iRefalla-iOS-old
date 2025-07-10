//
//  SubestacionesTableViewController.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 31/01/18.
//  Copyright © 2018 Pavel Balderrama. All rights reserved.
//

import UIKit

class SubestacionesTableViewController: TableViewSearchBar {

    var subestaciones: [Subestacion]?
    var selectedSubestacion: Subestacion?
    private var subestacionesFiltred: [Subestacion]?
    var eventoMayor: EventoMayor?
    var popPickerVC: AnyObject?
    
    override func viewDidLoad() {
        delegate = self //delegate TableViewProtocol
        super.viewDidLoad()
//        tableView.allowsMultipleSelectionDuringEditing = true
//        if eventoMayor != nil {
//            self.tableView.allowsSelection = false
//            let saveButton = UIBarButtonItem(image: #imageLiteral(resourceName: "guardarIcon.png"), style: .done, target: self, action: #selector(saveList))
//            self.navigationItem.rightBarButtonItem = saveButton
//            self.tableView.setEditing(true, animated: true)
//        }
        
        loadData()
        
    }

    private func loadData() {
        Subestacion.getAll() { (subestaciones) in
            self.subestaciones = subestaciones
            GlobalMainQueue.async {
                self.tableView.reloadData()
            }
        }
    }

    private func selectBanco(index: Int) {
        
        popPickerVC = nil
        // set delegate
        if #available(iOS 13.0.0, *) {
            popPickerVC = PickerValueViewController() as AnyObject
            (popPickerVC as! PickerValueViewController).rootView.delegate = self
            selectedSubestacion = subestaciones![index]
            if selectedSubestacion?.transformadores ?? 0 > 0 {
                let bancos = Array(1...selectedSubestacion!.transformadores).map {"T" + String($0)}
                let vc = popPickerVC as! PickerValueViewController
                vc.setLabels(labels: bancos)
                self.present(vc, animated: false, completion: nil)
    //            NotificationCenter.default.post(name: NSNotification.Name("reloadEventosMayores"), object: nil)
            }
        }
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

    // MARK: - Table view data @objc source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if searchBarActive {
            return subestacionesFiltred?.count ?? 0
        } else {
            return subestaciones?.count ?? 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let subestacion = selectedRow(index:indexPath.row)
        cell.textLabel?.text = "\(subestacion.clave) - \(subestacion.nombre)"
        cell.detailTextLabel?.text = subestacion._detalle
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if eventoMayor != nil {
            selectBanco(index: indexPath.row)
        }
    }

    // MARK: - Navigation

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return self.eventoMayor == nil
    }
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SubestacionToCircuitos" {
            if let index = tableView.indexPathForSelectedRow {
                let row = selectedRow(index: index.row)
                let controller = segue.destination as? CircuitosTableViewController
                controller?.subestacion = row.clave
            }
        }
    }
}

extension SubestacionesTableViewController: TableViewProtocol {
    
    func configure() -> ConfigTable {
        return ConfigTable(title: "Subestaciones", placeholder: "subestacion", scopeTitles: nil, searchBarHidden: true )
    }
    
    func selectedRow(index: Int) -> Subestacion {
        var row: Subestacion!
        if searchBarActive {
            row = subestacionesFiltred?[index]
        } else {
            row = subestaciones?[index]
        }
        return row
    }
    
    func filterContentForSearchText(searchBarText: String, scope: String? = "ALL") {
        subestacionesFiltred = subestaciones?.filter {
//            let zona = $0.zona.lowercased()
            let clave = $0.clave.lowercased()
            return searchBarText == "" || clave.contains(searchBarText.lowercased())
        }
        tableView.reloadData()
    }

}

extension  SubestacionesTableViewController: pickerProtocol {
    @available(iOS 13.0.0, *)
    func selected(selected: String? ) {
        if let banco = selected, let se = selectedSubestacion?.clave {
            var bancos = eventoMayor?.bancos ?? [String: [String]]()
            var bancosSE = Set(bancos[se] ?? [String]())
            bancosSE.insert(banco)
            bancos.updateValue(Array(bancosSE), forKey: se)
            eventoMayor?.setObject(bancos, forKey: "bancos")
            eventoMayor?.saveEventually()
        }
        popPickerVC?.dismiss()
    }
}

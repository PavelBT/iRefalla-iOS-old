//
//  CircuitosTableViewController.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 31/01/18.
//  Copyright © 2018 Pavel Balderrama. All rights reserved.
//

import UIKit

class CircuitosTableViewController: TableViewSearchBar {

    var subestacion: String?
    var circuitos: [Circuito]?
    var circuitosFilter: [Circuito]?
    var eventoMayor: EventoMayor?
    
    override func viewDidLoad() {
        delegate = self
        super.viewDidLoad()
        tableView.allowsMultipleSelectionDuringEditing = true
        if eventoMayor != nil {
            self.tableView.allowsSelection = false
            let saveButton = UIBarButtonItem(image: #imageLiteral(resourceName: "guardarIcon.png"), style: .done, target: self, action: #selector(saveList))
            self.navigationItem.rightBarButtonItem = saveButton
        }
        
        // observer for reload data
        loadData()
    }
    
//    func dismissView () {
//        dismiss(animated: true, completion: nil)
//    }
    
    private func loadData() {
        if circuitos != nil {
            tableView.reloadData()
        } else if let subestacion = self.subestacion {
            let params = queryParams("subestacion", subestacion, .equal)
            Circuito.getFilter(filter: [params]) { (data) in
                self.circuitos = data
                self.tableView.reloadData()
            }
        } else {
            Circuito.getAll(limit: 1200) { (data) in
                self.circuitos = data
                let circutosRem = self.eventoMayor?.circuitos ?? [Circuito]()
                self.circuitos = self.circuitos?.filter({ (c) -> Bool in
                    return !circutosRem.contains(c)
                })
                GlobalMainQueue.async {
                    self.tableView.setEditing(true, animated: true)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    @objc
    func saveList() {
        if let indexes = tableView.indexPathsForSelectedRows, indexes.count > 0 {
            var selectedCircuitos = [Circuito]()
            for index in indexes {
                selectedCircuitos.append(circuitos![index.row])
            }
            eventoMayor?.addUniqueObjects(from: selectedCircuitos, forKey: "circuitos")
            do {
                try eventoMayor?.save()
                tableView.setEditing(!tableView.isEditing, animated: true)
                self.dismissView()
            } catch {
                self.dismiss(animated: true) {
                    EventoMayor.showError(error: error as NSError)
                }
            }
            NotificationCenter.default.post(name: NSNotification.Name("reloadEventosMayores"), object: nil)
        }
    }
    
//    @IBAction func addButton(_ sender: Any) {
//        self.circuitos = nil
//        self.addButton?.isEnabled = false
//        self.loadData()
//        self.tableView.isEditing = true
//    }
    
    @IBAction func actionMenuButton(_ sender: Any) {
        if let indexes = tableView.indexPathsForSelectedRows, indexes.count > 0 {
            var selectedCircuitos = [Circuito]()
            for index in indexes {
                selectedCircuitos.append(circuitos![index.row])
            }
            Circuito.actionMenu(viewController: self, circuitos: selectedCircuitos)
        }
        tableView.setEditing(!tableView.isEditing, animated: true)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if searchBarActive {
            return circuitosFilter?.count ?? 0
        } else {
            return circuitos?.count ?? 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let circuito = selectedRow(index: indexPath.row)
        cell.textLabel?.text = circuito.clave
        cell.detailTextLabel?.text = circuito._detalle
        
        return cell
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "circuitoToregistros" {
            let controller = segue.destination as? CNNTableViewController
            let index = tableView.indexPathForSelectedRow
            controller?.circuito = circuitos?[index!.row]
        }
    }
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return !tableView.isEditing
    }
    
    @available(iOS 11.0, *)
     override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let row = self.selectedRow(index: indexPath.row)
        
        // poner el restablecimiento manual
        let restablecimiento = UIContextualAction(style: .normal, title: "% Rest") { (action, view, sucess) in
            let rests = self.eventoMayor?.restablecimientoManual
            let value = rests?[row.objectId ?? "none"] ?? 0
                
            AlertDialog.ShowAlert(viewController: self, title: "Restablecimiento", message: "Indicar el porcentaje de restablecimiento", dic: ["Avance %": String(value)],completion: { (fields) in
                if let rest = Int(fields?[0] ?? "0") {
                    let key = row.objectId ?? "none"
                    var restManual = self.eventoMayor?.restablecimientoManual ?? [String: Int]()
                    if rest == 0 {
                        restManual.removeValue(forKey: key)
                    } else {
                        restManual[key] = rest
                    }
                    self.eventoMayor?.restablecimientoManual = restManual
                    self.eventoMayor?.saveInBackground(block: { (sucess, err) in
                        if sucess {
                            tableView.setEditing(false, animated: true)
                            GlobalMainQueue.async {
                                self.tableView.reloadData()
                            }
                        }
                    })
                } else {
                    tableView.setEditing(false, animated: true)
                }
            })
         }
        
        // genenrar nota sin registro
        
        let nota = UIContextualAction(style: .normal, title: "Nota") { (action, view, sucess) in
//            view.backgroundColor = .lightGray
        }
        
        // borrar el circuito del evento mayor
        let delete = UIContextualAction(style: .destructive, title: "Borrar") { (action, view, sucess) in
           let row = self.selectedRow(index: indexPath.row)
           AlertDialog.Show(viewController: self, title: "Advertencia", message: "¿Esta seguro que desea borrar el circuito \(row.clave)?") { (isAcepted) in
               if isAcepted {
                   self.eventoMayor?.remove(row, forKey: "circuitos")
                   self.eventoMayor?.saveInBackground(block: { (success, error) in
                       if success {
                           self.circuitos?.remove(at: indexPath.row)
                           tableView.reloadData()
                       } else {
                           print(error?.localizedDescription as Any)
                       }
                   })
               } else {
                   tableView.setEditing(false, animated: true)
               }
           }
        }
         return UISwipeActionsConfiguration(actions: [restablecimiento, nota, delete])
     }
}


extension CircuitosTableViewController: TableViewProtocol {
    func configure() -> ConfigTable {
        let conf = ConfigTable(title: subestacion ?? eventoMayor?.nombre, placeholder: "circuitos", preferLargeTitles: false, scopeTitles: nil, searchBarHidden: false, searchBarEnable: false )
        
        return conf
    }
    
    func filterContentForSearchText(searchBarText: String, scope: String?) {
        circuitosFilter = circuitos?.filter {
            //            let zona = $0.zona.lowercased()
            let clave = $0.clave.lowercased()
            return searchBarText == "" || clave.contains(searchBarText.lowercased())
        }
        tableView.reloadData()
    }
    
    func selectedRow(index: Int) -> Circuito {
        var row: Circuito!
        if searchBarActive {
            row = circuitosFilter?[index]
        } else {
            row = circuitos?[index]
        }
        return row
    }
    
    
}


extension Circuito {
    
    static func actionMenu (viewController: UIViewController, circuitos: [Circuito]) {
        
        let verMapa = UIAlertAction(title: "Ver en Mapa", style: .default) { (alert) in
            let navcon = ActionMenuloadMap(circuitos: circuitos.map { $0.clave }, fallas: nil)
            viewController.present(navcon, animated: false, completion: nil)
        }
        
//        let compartir = UIAlertAction(title: "Compartir en...", style: .default) { (alert) in
//            let share = registros.map {$0._shareObject}.flatMap {$0}  as [AnyObject]
//            let vc = UIActivityViewController(activityItems: share, applicationActivities: nil)
//            viewController.present(vc, animated: true, completion: {
//                vc.viewDidLoad()
//            })
//        }
        
        var actions = [verMapa]
        
        if circuitos.count == 1, let circuito = circuitos.first {
            let nota = UIAlertAction(title: "Nota", style: .default) { (alert) in
                circuito.getNota(completition: { (nota) in
                    let share =   [nota] as [AnyObject]
                    let vc = UIActivityViewController(activityItems: share, applicationActivities: nil)
                    viewController.present(vc, animated: true, completion: {
                        vc.viewDidLoad()
                    })
                })
            }
            actions.append(nota)
        }
        
        AlertDialog.ShowAlert(viewController: viewController, title: "Selecciona la Accion", message: nil, actions: actions, fields: nil, completion: nil)
    }
    
    static private func ActionMenuloadMap(circuitos: [String]?, fallas: [FallaAnnotation]?) -> UINavigationController {
        let mapviewVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapViewVC") as! MapTilesViewController
        mapviewVC.circuitos = circuitos
        mapviewVC.fallasAnnotation = fallas
        return UINavigationController(rootViewController: mapviewVC)
    }
}

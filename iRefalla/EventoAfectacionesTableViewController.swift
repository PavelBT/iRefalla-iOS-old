//
//  EventoAfectacionesTableViewController.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 18/09/20.
//  Copyright © 2020 Pavel Balderrama. All rights reserved.
//

import UIKit
import Parse

class EventoAfectacionesTableViewController: UITableViewController {

    var eventoMayor: EventoMayor?
    var afectaciones = [PFObject]()
    fileprivate lazy var circuitosVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CircuitosVC") as! CircuitosTableViewController
    fileprivate lazy var subestacionesVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SubestacionesVC") as! SubestacionesTableViewController
    fileprivate lazy var lineasVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LineasVC") as! LineasATTableViewController
    var popPickerVC: AnyObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadData()
        self.title = eventoMayor?.nombre
  
        if #available(iOS 13.0.0, *) {
            popPickerVC = DatePickerViewController()
        } else {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancelar", style: .plain, target: self, action: #selector(dismissView))
        }
         
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.loadData), name: NSNotification.Name(rawValue: "reloadEventosMayores"), object: nil)
        
        self.navigationItem.rightBarButtonItems?.append(self.editButtonItem)
        
        // autosize cells
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableView.automaticDimension
        
    }
    @objc
    private func loadData() {
        let afectaciones = eventoMayor?.registros ?? [PFObject]()
        afectaciones.forEach { (data) in
            let rest = eventoMayor?.restablecimientoManual?[data.objectId ?? "none"]
            if let reg = data as? RegistroCNN, let rest = rest {reg.restablecimientoManual = rest}
            if let cir = data as? Circuito, let rest = rest { cir.restablecimientoManual = rest}
        }
        self.afectaciones = afectaciones
        self.tableView.reloadData()
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
        return afectaciones.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = afectaciones[indexPath.row]
        
        switch row.parseClassName {
        case "Registros":
            print("registro")
            var cellID = "CNNCell"
            let row = row as! RegistroCNN
            if row._atendido {
                cellID = "FallaCell"
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? CNNTableViewCell
            cell?.delegate = self
            cell?.registro = row
            return cell!
            
        case "Circuitos":
            print("circuitos")
            let row = row as? Circuito
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellCir", for: indexPath)
            cell.textLabel?.text = row?._title
            cell.detailTextLabel?.text = row?._detalle
            return cell
            
        case "LineasAT":
            print("Lineas AT")
            let row = row as? LineaAT
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellLinea", for: indexPath)
            cell.textLabel?.text = row?.clave
            cell.detailTextLabel?.text = row?._detalle
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellBancos", for: indexPath)
//            cell.textLabel?.text = row?.clave
//            cell.detailTextLabel?.text = row?._detalle
            return cell
        }
        
//        if let row = row as? RegistroCNN {
//            var cellID = "CNNCell"
//            if row._atendido {
//                cellID = "FallaCell"
//            }
//            let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? CNNTableViewCell
//            cell?.delegate = self
//            cell?.registro = row
//            return cell!
//        } else {
//            let row = row as? Circuito
//            let cell = tableView.dequeueReusableCell(withIdentifier: "cellCir", for: indexPath)
//            cell.textLabel?.text = row?._title
//            cell.detailTextLabel?.text = row?._detalle
//            return cell
//        }
    }


     @available(iOS 11.0, *)
         override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

            let row = afectaciones[indexPath.row]

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
                                    NotificationCenter.default.post(name: NSNotification.Name("reloadEventosMayores"), object: nil)
                                }
                            }
                        })
                    } else {
                        tableView.setEditing(false, animated: true)
                    }
                })
             }

            var actions =  [restablecimiento]
            
            // borrar el circuito del evento mayor

            if let circuito = row as? Circuito ?? (row as? RegistroCNN)?.circuito {
                let delete = UIContextualAction(style: .destructive, title: "Eliminar") { (action, view, sucess) in
                    AlertDialog.Show(viewController: self, title: "Advertencia", message: "¿Esta seguro que desea borrar el circuito \(circuito.clave)?") { (isAcepted) in
                        if isAcepted {
                            self.eventoMayor?.remove(circuito, forKey: "circuitos")
                            self.eventoMayor?.saveInBackground(block: { (success, error) in
                                if success {
                                    self.afectaciones.remove(at: indexPath.row)
                                    tableView.reloadData()
                                    NotificationCenter.default.post(name: NSNotification.Name("reloadEventosMayores"), object: nil)
                                } else {
                                    print(error?.localizedDescription as Any)
                                }
                            })
                        } else {
                            tableView.setEditing(false, animated: true)
                        }
                    }
                }
                actions.append(delete)
            }
            
            return UISwipeActionsConfiguration(actions: actions)
         }

    @IBAction func addButton(_ sender: Any) {
        let circuitoAction = UIAlertAction(title: "Circuitos", style: .default) { (action) in
            self.circuitosVC.eventoMayor = self.eventoMayor
            let navcon = UINavigationController(rootViewController: self.circuitosVC)
                    self.present(navcon, animated: true, completion: nil)
        }
        
        let transformadoresAction = UIAlertAction(title: "Bancos de Transformacion", style: .default) { (action) in
            self.subestacionesVC.eventoMayor = self.eventoMayor
            let navcon = UINavigationController(rootViewController: self.subestacionesVC)
                    self.present(navcon, animated: true, completion: nil)
        }
        
        let lineasAction = UIAlertAction(title: "Lineas de Alta Tension", style: .default) { (action) in
            self.lineasVC.eventoMayor = self.eventoMayor
            let navcon = UINavigationController(rootViewController: self.lineasVC)
                    self.present(navcon, animated: true, completion: nil)
        }
        
        let actions = [circuitoAction, transformadoresAction, lineasAction]
        AlertDialog.ShowAlert(viewController: self, title: "Tipo de evento", message: "Selecciona el tipo de evento", actions: actions, completion: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CNNToFalla" {
            if let index = self.tableView.indexPathForSelectedRow?.row, let row = afectaciones[index] as? RegistroCNN {
                if let destination = segue.destination as? ConsultaViewController {
                    destination.registro = row
                }
                if let destination = segue.destination as? CargaFallaTableViewController {
                    destination.registro = row
                }
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "CNNToFalla" {
            return !tableView.isEditing
        }
        return true
    }
    
}


extension EventoAfectacionesTableViewController: UsuariosButtonProtocol {
    func click(circuito: Circuito?) {
        if let circuito = circuito {
            //mostrar usuarios importanntes
            let params = [queryParams("circuito", circuito, .equal)]
            let uiController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UsuariosImpVC") as! UsuariosImportantesTableViewController
            uiController.filter = params
            let navcon = UINavigationController(rootViewController: uiController)
            self.present(navcon, animated: false, completion: nil)
        }
    }
    
}

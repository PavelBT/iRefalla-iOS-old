//
//  EventosMayoresTableViewController.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 18/01/19.
//  Copyright © 2019 Pavel Balderrama. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

class EventosMayoresTableViewController: TableViewSearchBar {
    
    private var eventosMayores: [EventoMayor]?
    private var editEvent: EventoMayor?
    private var isNewEvent: Bool = false
    private var dateTextField = UITextField()
    var dateVC: AnyObject?
    
    override func viewDidLoad() {
        delegate = self
        super.viewDidLoad()
        
        if #available(iOS 13.0.0, *) {
            dateVC = DatePickerViewController()
            (dateVC as? DatePickerViewController)?.rootView.delegate = self
        } else {
            // Fallback on earlier versions
        }
        
        self.tableView.allowsMultipleSelectionDuringEditing = false
                
        self.navigationItem.rightBarButtonItems?.append(self.editButtonItem)
        
        NotificationCenter.default.addObserver(self, selector: #selector(EventosMayoresTableViewController.reloadData), name: NSNotification.Name(rawValue: "reloadEventosMayores"), object: nil)
        
        // autosize cells
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableView.automaticDimension
        
        loadData()
        
        
    }
    
    @objc private func loadData() {
        EventoMayor.getAll { (data) in
            self.eventosMayores = data?.sorted { $0.fechaInicio > $1.fechaInicio }
            self.tableView.reloadData()
        }
    }
    
    @objc private func reloadData() {
        self.loadData()
    }
    
    @IBAction func addEvento(_ sender: Any) {
        isNewEvent = true
        let newEvent = EventoMayor()
        addEditEvento(evento: newEvent)
    }
    
    private func addEditEvento(evento: EventoMayor) {
        
        if #available(iOS 13.0.0, *) {
            self.editEvent = evento
            self.present((dateVC as! DatePickerViewController), animated: false, completion: nil)
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    @objc private func borrar(_ sender: UIBarButtonItem ) {
        if sender.title == "Editar" {
            sender.title = "Borrar"
            tableView.setEditing(true, animated: true)
        } else {
            
            
            sender.title = "Editar"
            tableView.setEditing(false, animated: true)
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return eventosMayores?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventoCell", for: indexPath) as? EventoMayorTableViewCell
        let row = eventosMayores?[indexPath.row]
        cell?.eventoMayor = row
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let nota = UIContextualAction(style: .normal, title: "Acciones") { (action, view, sucess) in
            let evento = self.eventosMayores![indexPath.row]
            EventoMayor.actionMenu(viewController: self, evento: evento)
           
        }
        
        nota.backgroundColor = .darkGray
        nota.image = #imageLiteral(resourceName: "button_yellow.png")
        
        return UISwipeActionsConfiguration(actions: [nota])
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let row = eventosMayores?[indexPath.row]
            AlertDialog.Show(viewController: self, title: "Advertencia", message: "Desea borrar el evento \(row!.nombre)") { (acept) in
                if acept {
                    row?.deleteInBackground(block: { (success, error) in
                        if success {
                            GlobalMainQueue.async {
                                self.eventosMayores?.remove(at: indexPath.row)
                                self.tableView.reloadData()
                            }
                        }
                    })
                }
            }
        }
    }
    
    @IBAction func bagButton(_ sender: Any) {
        
    }
    
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MayorToCircuitos" {
            let rootVC = segue.destination as? UINavigationController
            let controller = rootVC?.topViewController as? EventoAfectacionesTableViewController
            var evento = editEvent
            if let index = tableView.indexPathForSelectedRow {
                evento = eventosMayores?[index.row]
            }
            controller?.eventoMayor = evento
        }
    }
}


@available(iOS 12.0.0, *)
extension EventosMayoresTableViewController: TableViewProtocol {
    
    func configure() -> ConfigTable {
        return ConfigTable(title: "Eventos Mayores", placeholder: "eventos", scopeTitles: ["Abiertos", "Cerrados"], searchBarHidden: true, forceCancelButton: true)
    }
    
    func filterContentForSearchText(searchBarText: String, scope: String? = "ALL") {
//        subestacionesFiltred = subestaciones?.filter {
//            let zona = $0.zona.lowercased()
//            let clave = $0.clave.lowercased()
//            let scopeMatch: Bool = (scope == "ALL" || zona.contains(scope!.lowercased()))
//            return scopeMatch && clave.contains(searchBarText.lowercased())
//        }
    }
    
}

@available(iOS 13.0.0, *)
extension EventosMayoresTableViewController: newEventoProtocol {
    
//    var dateVC: UIHostingController<PopDatePickerUI>? {
//        let dc = DatePickerViewController()
//        dc?.rootView.delegate = self
//        return dc
//    }
    
    func inputDate(nombre: String, descripcion: String, fecha: Date) {
        
        (dateVC as? DatePickerViewController)?.dismiss(animated: true)
        editEvent?.nombre = nombre
        editEvent?.descripcion = descripcion
        editEvent?.fechaInicio = fecha
        
        if isNewEvent {
            isNewEvent = false
            self.eventosMayores?.append(editEvent!)
            
            // remove auto add circutos
//            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CircuitosVC") as! CircuitosTableViewController
//            vc.eventoMayor = editEvent
//            vc.tableView.setEditing(true, animated: false)
//            let navCon = UINavigationController(rootViewController: vc)
//            self.present(navCon, animated: true)
        } else {
            editEvent?.saveInBackground(block: { (success, err) in
                if success {
                    self.tableView.reloadData()
                }
            })
        }
        
    }
    
}


extension EventoMayor {
    
    static func actionMenu (viewController: UIViewController, evento: EventoMayor) {
        
        let verMapa = UIAlertAction(title: "Ver en Mapa", style: .default) { (alert) in
            let circuitos = evento.circuitos
            let navcon = ActionMenuloadMap(circuitos: circuitos?.map { $0.clave }, fallas: nil)
            viewController.present(navcon, animated: false, completion: nil)
        }
        
//        let compartir = UIAlertAction(title: "Compartir en...", style: .default) { (alert) in
//            let share = registros.map {$0._shareObject}.flatMap {$0}  as [AnyObject]
//            let vc = UIActivityViewController(activityItems: share, applicationActivities: nil)
//            viewController.present(vc, animated: true, completion: {
//                vc.viewDidLoad()
//            })
//        }
        
        
        let nota = UIAlertAction(title: "Nota", style: .default) { (alert) in
            evento.getNota(completition: { (nota) in
                let share =   [nota] as [AnyObject]
                let vc = UIActivityViewController(activityItems: share, applicationActivities: nil)
                viewController.present(vc, animated: true, completion: {
                    vc.viewDidLoad()
                })
            })
        }
        
        AlertDialog.ShowAlert(viewController: viewController, title: "Selecciona la Accion", message: nil, actions: [verMapa, nota], fields: nil, completion: nil)
    }
    
    static private func ActionMenuloadMap(circuitos: [String]?, fallas: [FallaAnnotation]?) -> UINavigationController {
        let mapviewVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapViewVC") as! MapTilesViewController
        mapviewVC.circuitos = circuitos
        mapviewVC.fallasAnnotation = fallas
        return UINavigationController(rootViewController: mapviewVC)
    }
}

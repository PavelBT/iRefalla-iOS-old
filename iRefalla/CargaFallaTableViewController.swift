//
//  CargaFallaTableViewController.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 03/05/17.
//  Copyright © 2017 Pavel Balderrama. All rights reserved.
//

import UIKit
import CoreLocation

fileprivate let sectionLabel = ["Instalacion", "Informacion de la Falla", "Ubicacion"]

class CargaFallaTableViewController: UITableViewController {

    @IBOutlet weak var subestacionLabel: UILabel!
    @IBOutlet weak var circuitoLabel: UILabel!
    @IBOutlet weak var ramalLabel: UITextField!
    @IBOutlet weak var causaLabel: UILabel!
    @IBOutlet weak var observacionesLabel: UILabel!
    @IBOutlet weak var fotografiasLabel: UILabel!
    @IBOutlet weak var ubicacionSwitch: UISwitch!
    @IBOutlet weak var climaLabel: UILabel!
    @IBOutlet weak var restablecimientoLabel: UILabel!
    
    
    var registro: RegistroCNN?
    private var messages = [Mensaje]() //  { return Mensaje.getLocalLabel(label: newItemsLabel) }
    private var images : [Image] { return Image.getLocalLabel(label: newItemsLabel) }
    private var causa: Causa?  { return  Causa.getLocalLabel(label: newItemsLabel).last ?? registro?.causa }

    override func viewDidLoad() {
        super.viewDidLoad()

        //tableView.separatorColor = appColor
        
        self.title = registro?._circuito
        loadData()
        configureView()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureUpdateView()
    }
    
    private func loadData() {
        
        // Cargar valores de variables
        self.messages = [self.registro!._mensajeCNN]
        let params = queryParams("id_cnn", registro?.id_cnn, .equal)
        Mensaje.getFilter(filter: [params]) { (messages) in
            self.messages = self.messages + (messages ?? [Mensaje]())
            self.observacionesLabel?.text =  (self.messages.last?.texto ?? "").uppercased()
        }
        
    }
    
    private func configureView() {
        subestacionLabel?.text = registro?._subestacion
        circuitoLabel?.text = registro?._circuito
        ramalLabel?.text = self.registro?.ramal == "" ? nil : self.registro?.ramal
        climaLabel?.text = registro?.clima_resumen?["texto"]
        restablecimientoLabel?.text = registro?.restablecimientos?.count.description
    }
    
    private func configureUpdateView() {
        messages = messages + Mensaje.getLocalLabel(label: newItemsLabel)
        causaLabel?.text = causa?.nombre ?? "Seleccionar"
        observacionesLabel?.text = messages.last?.texto ?? registro?.observacion
        fotografiasLabel?.text = "\(images.count) Foto"
    }
    
    @IBAction func ubicacionButton(_ sender: UISwitch) {
        if sender.isOn {
            let mapviewVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapViewVC") as! MapTilesViewController
            mapviewVC.circuitos = [(registro?._circuito)!]
            mapviewVC.addLocation = true
            let navCon = UINavigationController(rootViewController: mapviewVC)
            navCon.modalPresentationStyle = .fullScreen
            present(navCon, animated: false, completion: nil)
        } else {
            let ubicacion = Ubicacion.getLocalLabel(label: newItemsLabel).first
            ubicacion?.unpinLabel(label: newItemsLabel)
        }
    }
    
    
    @IBAction func saveButton(_ sender: Any) {
        
//        registro?.ramal = self.ramalLabel.text
//        registro?.causa = causa
//        registro?.saveEventually() // GRABA LA CAUSA
//        causa?.unpinLabel(label: newItemsLabel) // borra local
        registro?.updateRegistro(ramal: self.ramalLabel.text)
        
//        if messages.count > 0 || images.count > 0 || Ubicacion.getLocalLabel(label: newItemsLabel).first != nil {
//        }
         
        self.dismiss(animated: false, completion: nil)
        
//        if messages.count > 0, images.count > 0, causa != nil {
//            registro?.ramal = self.ramalLabel.text
//            registro?.causa = causa
//            registro?.saveEventually() // GRABA LA CAUSA
//            causa?.unpinLabel(label: newItemsLabel) // borra local
//            registro?.updateRegistro()
//
//            self.dismiss(animated: false, completion: nil)
//        } else {
//            AlertDialog.ShowAlert(viewController: self, title: "Falta Informacion", message: "Asegura que esten debidamente llenadas las observaciones, fotografia y causa", actions: nil, fields: nil, completion: nil)
//        }
    }
    
    @IBAction func actionButton(_ sender: Any) {
        RegistroCNN.actionMenu(viewController: self, registros: [self.registro!])
    }
    
    
    // MARK: TableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch (indexPath.section, indexPath.row) {
        case  (1,0):
            let causasVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CausasVC") as! CausasTableViewController
            let navCon = UINavigationController(rootViewController: causasVC)
            navCon.modalPresentationStyle = .fullScreen
            present(navCon, animated: true, completion: nil)
        case (1,1):
            let messagesVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MessagesVC") as! MessagesCollectionViewController
            let navCon = UINavigationController(rootViewController: messagesVC)
            navCon.modalPresentationStyle = .fullScreen
            messagesVC.currentMessages = self.messages
            present(navCon, animated: false, completion: nil)
        case (1,2):
             let imagesVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ImageCollectionVC") as! ImageCollectionViewController
            let navCon = UINavigationController(rootViewController: imagesVC)
            navCon.modalPresentationStyle = .fullScreen
            present(navCon, animated: true, completion: nil)
        case (1,3):
            let restVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RestablecimientosVC") as! RestablecimientosTableViewController
            restVC.restablecimientos = registro?._restablecimientos
            let navCon = UINavigationController(rootViewController: restVC)
            present(navCon, animated: true, completion: nil)
        default:
            return
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = navBarColor
        let label = UILabel(frame: CGRect(x: 20, y: 10, width: 220, height: 20))
        label.text = sectionLabel[section]
        label.font = UIFont(name: "System", size: 16)
        label.textColor = .white
        view.addSubview(label)
        return view
    }
    
}


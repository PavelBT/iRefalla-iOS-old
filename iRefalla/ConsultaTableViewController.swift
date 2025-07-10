//
//  ConsultaTableViewController.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 02/10/17.
//  Copyright © 2017 Pavel Balderrama. All rights reserved.
//

import UIKit
import MapKit

class ConsultaTableViewController: UITableViewController, MKMapViewDelegate {
    
    @IBOutlet weak var observacionesLabel: UILabel!
    @IBOutlet weak var fotografiasLabel: UILabel!
    @IBOutlet weak var ubicacionSwitch: UISwitch!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var climaDetailLabel: UILabel!
    @IBOutlet weak var restablecimientoLabel: UILabel!
    @IBOutlet weak var ramalLabel: UITextField!
    @IBOutlet weak var causaLabel: UILabel!
    
    fileprivate var mapVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapViewVC") as! MapTilesViewController
    fileprivate var causaVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CausasVC") as! CausasTableViewController
    private var messages = [Mensaje]()
    private var images = [Image]()
    private var fallaAnnotation: FallaAnnotation?
    private var causa: Causa?  { return  Causa.getLocalLabel(label: newItemsLabel).last ?? registro?.causa }
    var registro: RegistroCNN!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let saveButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "guardarIcon.png"), style: .plain, target: self, action: #selector(saveButton))

        self.parent?.navigationItem.rightBarButtonItems! += [saveButtonItem]
        loadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureUpdateView()
    }
    
    private func loadData() {
        
        if let clima = registro.clima_resumen?["texto"] {
            climaDetailLabel?.text = clima
        }
        
        // Cargar valores de variables
        self.messages = [self.registro._mensajeCNN]
        let params = queryParams("id_cnn", registro.id_cnn, .equal)
        Mensaje.getFilter(filter: [params]) { (messages) in
            self.messages = self.messages + (messages ?? [Mensaje]())
            self.observacionesLabel?.text =  (self.messages.last?.texto ?? "").uppercased()
        }
        Image.getFilter(filter: [params]) { (images) in
            self.images = images ?? [Image]()
            let imageCount = images?.count ?? 0
            self.fotografiasLabel?.text = String(imageCount) + " foto"
        }
        
        fallaAnnotation = registro._fallaAnnotation
        loadAnnotationMap()
        ubicacionSwitch.isEnabled = fallaAnnotation == nil // desibilitado si ya esta cargada la ubicacion
        
        restablecimientoLabel?.text = (registro.restablecimientos?.count)?.description
        
    }
    
    private func configureUpdateView() {
        let msg = Mensaje.getLocalLabel(label: newItemsLabel)
        observacionesLabel?.text = (msg.count > 0 ? msg.last?.texto : messages.last?.texto ?? registro?.observacion)?.uppercased()
        let img = Image.getLocalLabel(label: newItemsLabel)
        fotografiasLabel?.text = "\(images.count + img.count) Foto"
        if let ubi = Ubicacion.getLocalLabel(label: newItemsLabel).last {
            fallaAnnotation = FallaAnnotation(title: registro.causa?.nombre, subtitle: registro._mensajeCNN.texto, coordinate: ubi._coordinate)
            loadAnnotationMap()
            ubicacionSwitch.isOn = true
        } else if ubicacionSwitch.isEnabled {
            ubicacionSwitch.isOn = false
            loadAnnotationMap(delete: true)
        }
        
        // agregado el 28/08/2020 v2.2.2
        causaLabel.text = causa?.nombre ?? "Seleccionar"
        if registro.tipoNovedadOrigen == "R" {
            ramalLabel?.text = self.registro?.ramal == "" ? nil : self.registro?.ramal
        }  else {
            ramalLabel.isEnabled = false
        }
        
        tableView.reloadData()
    }
//    private func configureView() {
//        observacionesLabel?.text =  (messages.last?.texto ?? registro._mensajeCNN.texto ?? "").uppercased()
//        fotografiasLabel?.text = String(images.count) + " foto"
//        loadAnnotationMap()
//
//        self.tableView.reloadData()
//    }
    
    private func loadAnnotationMap(delete: Bool = false) {
        if let falla = fallaAnnotation {
            if delete {
                self.mapView.removeAnnotation(fallaAnnotation!)
            } else {
                self.mapView.showAnnotations([falla], animated: true)
                let region = MKCoordinateRegion.init(center: falla.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1) )
                self.mapView.setRegion(region, animated: true)
            }
        }
    }
    
    @objc private func saveButton() {
        registro?.updateRegistro(ramal: ramalLabel.text)
        self.parent?.dismiss(animated: true, completion: nil)
            
    }
    
    
    @IBAction func ubicacionButton(_ sender: UISwitch) {
        if sender.isOn {
            let navCon = UINavigationController(rootViewController: mapVC)
            mapVC.addLocation = true
            mapVC.circuitos = [registro._circuito]
            present(navCon, animated: true, completion: nil)
        } else {
            Ubicacion.unPinAllLabel(label: newItemsLabel)
            loadAnnotationMap(delete: true)
            registro.ubicacion = nil
        }
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch (indexPath.section, indexPath.row) {
        case  (0,0):
            let messagesVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MessagesVC") as! MessagesCollectionViewController
            let navCon = UINavigationController(rootViewController: messagesVC)
            messagesVC.currentMessages = self.messages
            present(navCon, animated: true, completion: nil)
        case (0,1):
            let imagesVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ImageCollectionVC") as! ImageCollectionViewController
            let navCon = UINavigationController(rootViewController: imagesVC)
            imagesVC.currentImages = self.images
            present(navCon, animated: true, completion: nil)
        case (0,2):
            let restVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RestablecimientosVC") as! RestablecimientosTableViewController
            restVC.restablecimientos = registro?._restablecimientos
            let navCon = UINavigationController(rootViewController: restVC)
            present(navCon, animated: true, completion: nil)
        case (1,1):
        let navCon = UINavigationController(rootViewController: causaVC)
        navCon.modalPresentationStyle = .fullScreen
        present(navCon, animated: true, completion: nil)
            
        case (2,1):
            let navCon = UINavigationController(rootViewController: mapVC)
            if let falla = fallaAnnotation {
                mapVC.fallasAnnotation = [falla]
            }
            mapVC.circuitos = [registro._circuito]
            present(navCon, animated: true, completion: nil)
        default:
            return
        }
    }

}

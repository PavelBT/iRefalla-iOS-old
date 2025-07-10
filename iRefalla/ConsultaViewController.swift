//
//  ConsultaViewController.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 29/09/17.
//  Copyright © 2017 Pavel Balderrama. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ConsultaViewController: UIViewController {
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var tableView: UIView!
    @IBOutlet weak var titleLeftLabel: UILabel!
    @IBOutlet weak var titleRightLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var causaLabel: UILabel!
    @IBOutlet weak var restablecimientoLabel: UILabel!
    @IBOutlet weak var eventosLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var proteccionLabel: UILabel!
    
    fileprivate var consultaTVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "consultaTVC") as! ConsultaTableViewController
    
    var registro: RegistroCNN?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Cambiar el color al View
        backgroundView.backgroundColor = navBarColor
        // Title
        
        self.title = registro?._circuito
        
        configureView()
        loadTableController()

    }
 
    fileprivate func configureView() {
        if let registro = registro {
            // Title
            let circuito = registro._circuito, tipo = registro.tipoNovedadOrigen
            titleLeftLabel?.text = tipo + " | " + circuito
            // Title 2
            let ramal = registro.ramal
            titleRightLabel?.text = ramal
            let fecha = registro.fechaHoraInicio.toStringFormatter, clientes = registro._clientes, mw = registro.demandaAproximada
            detailLabel?.text = NSString(format: "%@ | Clientes: %i MW: %1.f", fecha!, clientes, mw) as String
            // Subtitle 2
            eventosLabel?.text = registro.circuito?._eventos._eventosResumen
            // Restablecimiento
            let duracion = registro._duracion, restablecimiento = registro._restablecimiento
            restablecimientoLabel?.text = "\(restablecimiento)% (\(duracion) min)"
            if restablecimiento < 100 {
                restablecimientoLabel.textColor = UIColor.red
            } else {
                restablecimientoLabel.textColor = UIColor.white
            }
            // Causas y foto
            self.causaLabel?.text = registro._causa
            
            self.proteccionLabel.text = registro.proteccion?._protecciones ?? ""
            
            registro.thumbnail?.getDataInBackground { (data, error) in
                if let data = data {
                    self.imageView?.image = UIImage(data: data)
                }
            }
        }
    }
    
    
    fileprivate func loadTableController() {
        consultaTVC.registro = self.registro!
        addChild(consultaTVC)
        let width = self.tableView.bounds.width
        let height = self.tableView.bounds.height
        consultaTVC.view.frame = CGRect(x: 0, y: 0, width: width , height: height)
        tableView.addSubview(consultaTVC.view)
        consultaTVC.didMove(toParent: self)
    }
    
    
    @IBAction func actionButton(_ sender: Any) {
        RegistroCNN.actionMenu(viewController: self, registros: [self.registro!])
    }

}

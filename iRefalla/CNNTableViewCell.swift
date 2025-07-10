//
//  RegistroCNNTableViewCell.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 21/04/17.
//  Copyright © 2017 Pavel Balderrama. All rights reserved.
//

import UIKit
import PDFReader
import MRProgress

protocol UsuariosButtonProtocol {
    func click(circuito: Circuito?)
}

class CNNTableViewCell: UITableViewCell {
    
    // CNN cell
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var title2Label: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var subtitle2Label: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var proteccionLabel: UILabel!
    @IBOutlet weak var eventosLabel: UILabel!
    @IBOutlet weak var bagButton: UIButton!
    @IBOutlet weak var UsuariosImpLabel: UILabel!
    
    // Falla Cell
    @IBOutlet weak var subtitle3Label: UILabel!
    @IBOutlet weak var fallaImageView: UIImageView!
    
    var registro: RegistroCNN? {
        didSet {
            loadCell()
        }
    }
    
    var delegate: UsuariosButtonProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bagButton?.layer.cornerRadius = 18
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        stackView?.subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        bagButton?.titleLabel?.text = nil
        bagButton?.isHidden = true
    }
    
    func loadCell() {
        if let registro = self.registro {
            // Title
            let circuito = registro._circuito, tipo = registro.tipoNovedadOrigen
            titleLabel?.text = tipo + " | " + circuito
            // Title 2
            let ramal = registro.ramal ?? ""
            let proteccion = registro.proteccion?._protecciones
            title2Label?.text = ramal
            proteccionLabel?.text = proteccion
            // eventos
            eventosLabel?.text = registro.circuito?._eventos._eventosResumen
            // detail 1
            detailLabel?.text = registro.observacion
            // Subtitle
            let fecha = registro.fechaHoraInicio.toStringFormatter ?? "", clientes = registro._clientes, mw = registro._mw
            subtitleLabel?.text = NSString(format: "%@ | Clientes: %i MW: %1.f", fecha, clientes, mw) as String
            // Subtitle 2
            // Restablecimiento
            let duracion = registro._duracion, restablecimiento = registro._restablecimiento
            subtitle2Label?.text = "\(restablecimiento)% \n(\(duracion) min)"
            if restablecimiento < 100 {
                subtitle2Label.textColor = UIColor.red
            } else {
                subtitle2Label.textColor = UIColor.black
            }
            // Causa
            self.subtitle3Label?.text = registro._causa
            
            // Imagen
            registro.thumbnail?.getDataInBackground { (data, error) in
                if let data = data {
                    self.fallaImageView?.image = UIImage(data: data)
                }
            }
//            // Reportes de fallas
//            if let _ = registro.reportePreURL {
//                loadButton(tipoReporte: .preliminar)
//            }
//            if let _ = registro.reporteDefURL {
//                loadButton(tipoReporte: .definitivo)
//            }
            // BAG
            
            if let numUI = registro.circuito?.usuariosImportantes, numUI.intValue > 0 {
                self.bagButton?.isHidden = false
                self.UsuariosImpLabel?.text = numUI.stringValue
            }
        }
    }
    
//    // CREA BOTON EN LAS CELDAS
//    fileprivate func loadButton(tipoReporte: tipoReporte) {
//        let pdfButton = UIButton()
//        pdfButton.frame = CGRect(x: 0, y: 0, width: 24, height: 26)
//        let image = UIImage(named: tipoReporte.rawValue)
//        pdfButton.setImage(image, for: .normal)
//        pdfButton.tag = tipoReporte.hashValue
//        let constraintW = NSLayoutConstraint(item: pdfButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width  , multiplier: 1, constant: 24)
//        let constraintH = NSLayoutConstraint(item: pdfButton, attribute: .height , relatedBy: .equal, toItem: nil, attribute: .height  , multiplier: 1, constant: 26)
//        pdfButton.addConstraint(constraintW)
//        pdfButton.addConstraint(constraintH)
//        pdfButton.addTarget(self, action: #selector(self.loadPDF(sender:)), for: .touchUpInside)
//
//        stackView?.addArrangedSubview(pdfButton)
//    }
    
//    // DESCARGA EL PDF Y PRESENTAR EL CONTROLLER
//    @IBAction func loadPDF(sender: UIButton) {
//        let tipo: tipoReporte = sender.tag == 0 ? .preliminar : .definitivo
//        let controller = self.controller as? CNNTableViewController
//        MRProgressOverlayView.showOverlayAdded(to: controller?.navigationController?.view, title: "Descargando", mode: .indeterminateSmall, animated: true)
//        // DESCARGAR REPORTE
//
//    }
    
    // BUTTON MOSTRAR USUARIOS IMPORTANTES
    @IBAction func bagButton(_ sender: Any) {
        delegate?.click(circuito: self.registro?.circuito)
    }
}

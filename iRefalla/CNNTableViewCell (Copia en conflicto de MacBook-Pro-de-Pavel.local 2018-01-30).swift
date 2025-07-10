//
//  RegistroCNNTableViewCell.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 21/04/17.
//  Copyright © 2017 Pavel Balderrama. All rights reserved.
//

import UIKit
import PDFKit

class CNNTableViewCell: UITableViewCell {
    
    // CNN cell
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var title2Label: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var subtitle2Label: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    
    // Falla Cell
    @IBOutlet weak var subtitle3Label: UILabel!
    @IBOutlet weak var fallaImageView: UIImageView!
    
    var registro: RegistroCNN? {
        didSet {
            loadCell()
        }
    }
    weak var controller: UIViewController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
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
    }
    
    func loadCell() {
        if let registro = self.registro {
            // Title
            let subestacion = registro.subestacion, circuito = registro.circuito, tipo = registro.tipo
            titleLabel?.text = tipo + " | " + subestacion + " - " + circuito
            // Title 2
            let ramal = registro.ramal
//            let eventos = registro.eventos ?? Eventos()
            title2Label?.text = ramal  // + " (Rec: \(eventos.recierres) , Perm: \(eventos.permanentes))"
            // detail 1
            let comentario = registro.comentarios?.first
            detailLabel?.text = comentario?.texto
            // Subtitle
            let fecha = registro.fecha.stringFormatter ?? "", clientes = registro.usuarios, mw = registro.mw
            subtitleLabel?.text = NSString(format: "%@ | Clientes: %i MW: %1.f", fecha, clientes, mw) as String
            // Subtitle 2
            // Restablecimiento
            let duracion = registro.duracion ?? -1, restablecimiento = registro.restablecimiento ?? 0
            subtitle2Label?.text = "\(restablecimiento)% \n(\(duracion) min)"
            if restablecimiento < 100 {
                subtitle2Label.textColor = UIColor.red
            } else {
                subtitle2Label.textColor = UIColor.black
            }
            // Causa
            if let causaId = registro.causa  {
                let causa = Causa.getByID(id: causaId) as? Causa
                subtitle3Label?.text = causa?.nombre
            }
            if let url = registro.imagenes?.first?.thumbnail {
                fallaImageView?.downloadedFrom(url: url)
            }
            // Reportes de fallas
            if let reportePreliminar = registro.reportePreURL {
                loadButton(tipoReporte: .preliminar)
            }
            if let reporteDefinitivo = registro.reporteDefURL {
                loadButton(tipoReporte: .definitivo)
            }
        }
    }
    
    fileprivate func loadButton(tipoReporte: tipoReporte) {
        let pdfButton = UIButton()
        pdfButton.frame = CGRect(x: 0, y: 0, width: 24, height: 26)
        let image = UIImage(named: tipoReporte.rawValue)
        pdfButton.setImage(image, for: .normal)
        pdfButton.tag = tipoReporte.hashValue
        let constraintW = NSLayoutConstraint(item: pdfButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width  , multiplier: 1, constant: 24)
        let constraintH = NSLayoutConstraint(item: pdfButton, attribute: .height , relatedBy: .equal, toItem: nil, attribute: .height  , multiplier: 1, constant: 26)
        pdfButton.addConstraint(constraintW)
        pdfButton.addConstraint(constraintH)
        pdfButton.addTarget(self, action: #selector(self.loadPDF(sender:)), for: .touchUpInside)

        stackView?.addArrangedSubview(pdfButton)
    }
    @IBAction func loadPDF(sender: UIButton) {
        let controller = self.controller as? CNNTableViewController
        let targetURL = URL(string: "http://sgdapp.mx/reportes/preliminar/PRE_72D638F3-6CFE-460D-A942-C32CBF48DFC7.pdf")!
        if #available(iOS 11.0, *) {
            let pdfView = PDFView(frame: controller!.view.frame)
            let doc = PDFDocument(url: targetURL)
            pdfView.document = doc
            controller?.view.addSubview(pdfView)
        } else {
            // Fallback on earlier versions
        }
//
//        if sender.tag == 0 {
//            let webView = UIWebView(frame: controller!.view.frame)
//            let targetURL = URL(string: "http://sgdapp.mx/reportes/preliminar/PRE_72D638F3-6CFE-460D-A942-C32CBF48DFC7.pdf")!
//            let request = URLRequest(url: targetURL)
//            webView.loadRequest(request)
//
//            controller?.view.addSubview(webView)
//        } else {
//
//        }
    }
}

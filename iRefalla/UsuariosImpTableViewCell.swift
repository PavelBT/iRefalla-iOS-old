//
//  UsuariosImpTableViewCell.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 21/04/20.
//  Copyright © 2020 Pavel Balderrama. All rights reserved.
//

import UIKit
import MapKit

protocol MapButtonDelegate {
    func mapButtonClick(annotation: MKAnnotation)
}

class UsuariosImpTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imagenView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var telefonoButton: UIButton!
    @IBOutlet weak var mapaButton: UIButton!
    
    var usuarioImp: UsuarioImportante? {
        didSet {
            self.configureCell()
        }
    }

    private var telefono: URL? {
        if let tel = usuarioImp?.telefono, let url = NSURL(string: "tel://\(tel)"), UIApplication.shared.canOpenURL(url as URL) {
            return url as URL
        }
        return nil
    }
    
    var delegate: MapButtonDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.telefonoButton?.isHidden = true
        self.mapaButton?.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func configureCell() {
        if let usuarioImp = usuarioImp {
            titleLabel?.text = usuarioImp.nombre
            titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 14)
            detailLabel?.text = usuarioImp.direccion
            subtitleLabel?.text = usuarioImp.contacto
            imageView?.image = usuarioImp.tipo.getIcon()
            telefonoButton?.isHidden = usuarioImp.telefono == nil
            mapaButton?.isHidden = usuarioImp.ubicacion == nil
        }
    }
    @IBAction func telefonoButton(_ sender: Any) {
        if let url = telefono {
            UIApplication.shared.open(url as URL)
        }
    }
    @IBAction func mapaButton(_ sender: Any) {
        if let mapItem = self.usuarioImp?.annotation {
            delegate?.mapButtonClick(annotation: mapItem)
        }
    }
    
}

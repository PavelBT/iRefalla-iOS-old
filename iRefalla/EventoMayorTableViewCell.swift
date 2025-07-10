//
//  EventoMayorTableViewCell.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 18/09/20.
//  Copyright © 2020 Pavel Balderrama. All rights reserved.
//

import UIKit

class EventoMayorTableViewCell: UITableViewCell {

    @IBOutlet weak var nombreLabel: UILabel!
    @IBOutlet weak var resumenLabel: UILabel!
    @IBOutlet weak var afectacionesLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var restablecimientoLabel: UILabel!
    @IBOutlet weak var fechaLabel: UILabel!
    @IBOutlet weak var causaLabel: UILabel!
    @IBOutlet weak var bagLabel: UILabel!
    
    var eventoMayor: EventoMayor? {
        didSet {
            loadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func loadData() {
        if let evento = eventoMayor {
            nombreLabel?.text = evento.nombre
            resumenLabel?.text = evento.instalaciones?.description.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
            afectacionesLabel?.text = evento._title
            detailLabel?.text = evento._detalle
            fechaLabel?.text = evento.fechaInicio.toStringFormatter
            causaLabel?.text = evento.descripcion
            bagLabel?.text = String(evento.usuariosImportantes)
            // restablecimiento
            let duracion =  evento.fechaFin != nil ? Int((evento.fechaFin!.timeIntervalSince(evento.fechaInicio) /  60)) : Int(evento.fechaInicio.timeIntervalSinceNow / 60) * -1// convertir a minutos
            restablecimientoLabel?.text = NSString(format: "%i%%\n(%i min)", evento.restablecimiento, duracion) as String
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

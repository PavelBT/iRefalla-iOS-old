//
//  RegistroFalla.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 20/04/17.
//  Copyright © 2017 Pavel Balderrama. All rights reserved.
//

import Foundation
import Parse

enum tipoReporte: String {
    case preliminar = "pdfIconP"
    case definitivo = "pdfIconD"
}

class RegistroCNN: PFObject {
    @NSManaged var id_cnn: String
    @NSManaged var fechaHoraInicio: Date
    @NSManaged var fechaHoraFin: Date?
    @NSManaged var zona: String
    @NSManaged var division: String
    @NSManaged var cveSubestacion: String?
    @NSManaged var cveCircuito: String?
    @NSManaged var circuito: Circuito?
    @NSManaged var cveLinea: String?
    @NSManaged var ramal: String?
    @NSManaged var tipoNovedadOrigen: String
    @NSManaged var usuariosAproximados: NSNumber
    @NSManaged var demandaAproximada: NSDecimalNumber
    @NSManaged var observacion: String?
    @NSManaged var porcentajeDentro: NSNumber?
    @NSManaged var duracion: NSNumber?
    @NSManaged var nombreCausa: String?
    @NSManaged var proteccion: UcmEvent?
    @NSManaged var restablecimientos: [[String: AnyObject]]?
    
    // falla cargada
    @NSManaged var causa: Causa?
    @NSManaged var thumbnail: PFFileObject?
    @NSManaged var ubicacion: Ubicacion?
    
    @NSManaged var clima_resumen: [String: String]?
    var reportePreURL:String?
    var reporteDefURL:String?
    
    // restablecimiento manual para evento mayor
    var restablecimientoManual: Int?

    func updateRegistro(ramal: String?) {
        
        if let ramal = ramal, ramal != "" {
            self.ramal = ramal
        }
        
        if let causa = Causa.getLocalLabel(label: newItemsLabel).last {
            self.causa = causa
            causa.unpinLabel(label: newItemsLabel)
        }

        if let ubicacion = Ubicacion.getLocalLabel(label: newItemsLabel).first {
            ubicacion.id_cnn = self.id_cnn
            self.ubicacion = ubicacion
            ubicacion.unpinLabel(label: newItemsLabel)
        }
        
        self.saveEventually()
        
        let messages = Mensaje.getLocalLabel(label: newItemsLabel)
        let imagenes = Image.getLocalLabel(label: newItemsLabel)
        
        messages.forEach {
            $0.id_cnn = self.id_cnn
            $0.saveEventually()
            $0.unpinLabel(label: newItemsLabel)
        }
        
        imagenes.forEach {
            $0.id_cnn = self.id_cnn
            $0.saveEventually()
            $0.unpinLabel(label: newItemsLabel)
        }
    }
    
    func getNota(tipo: String, completition: @escaping (String?) -> Void) {
        let params = ["registro": self.id_cnn] as [String: String]
        PFCloud.callFunction(inBackground: tipo, withParameters: params) { (result, error) in
            print(result as Any)
            if error == nil, let nota = result as? String {
                completition(nota)
            } else {
                print(error as Any)
                completition(nil)
            }
        }
    }
    
}

extension RegistroCNN {
    var _subestacion: String {return cveSubestacion?.extractLeft(offset: 3) ?? cveLinea?.extractLeft(offset: 3) ?? ""}
    var _circuito: String {
        return cveCircuito ?? cveLinea ?? _subestacion
    }
    
    var _causa: String? {
        return causa?.nombre ?? nombreCausa
    }
    
    var _mensajeCNN: Mensaje {
        let message = Mensaje(texto: observacion ?? "")
        message.userName = "CNN"
        message.usuario = nil
        message.fecha = self.fechaHoraInicio
        return message
    }
    var _restablecimiento: Int {return Int(truncating:  NSNumber(value: max(Int(truncating: porcentajeDentro ?? 0), restablecimientoManual ?? 0)))}
    var _mw: Float {return Float(truncating: demandaAproximada)}
    var _clientes: Int {return Int(truncating: usuariosAproximados)}
    var _duracion: Int {
        if _restablecimiento == 100 {
            return Int((fechaHoraFin?.timeIntervalSince(fechaHoraInicio) ?? 0) / 60)
        } else {
            let dur = fechaHoraInicio.timeIntervalSinceNow
            return Int(dur / -60)
        }
    }
    var _atendido: Bool {
        return (self.thumbnail != nil || self.ubicacion != nil)
    }
    
    var _shareObject: [AnyObject] {
        var object = [AnyObject]()
        let text = "\(fechaHoraInicio.toStringFormatter ?? "")\n\(_subestacion) - \(_circuito), causa: \(_causa!), usuarios: \(_clientes), MW: \(_mw)\n\(_mensajeCNN.texto!)\n"
        if let data = try? thumbnail?.getData(), data != nil {
            object.append(UIImage(data: data!)!)
        }
        object.append(text as AnyObject)
        return object
    }
    
    var _restablecimientos: [Restablecimiento] {
        var array = [Restablecimiento]()
        for restablecimiento in restablecimientos ?? [[String: AnyObject]]() {
            array.append(Restablecimiento(dic: restablecimiento))
        }
        let iniRest = ["relevador": _circuito, "equipo": "FALLA INICIAL", "fechaHoraDisparo": fechaHoraInicio, "porcentajeDentro": 0, "usuarios": _clientes] as [String : AnyObject]
        array.append(Restablecimiento(dic: iniRest))
        return array
    }
    
    var _fallaAnnotation: FallaAnnotation? {
        if let coord = ubicacion?._coordinate {
            return FallaAnnotation(title: causa?.nombre, subtitle: _mensajeCNN.texto, coordinate: coord)
        }
        return nil
    }
}

extension RegistroCNN: PFSubclassing {
    static func parseClassName() -> String {
        return "Registros"
    }
}

extension RegistroCNN: ParseManager {
    
    static var storePolicy: storePolicy {
        return .cache
    }
    
    static var sortDefault: [NSSortDescriptor]? {
        return [NSSortDescriptor(key: "fechaHoraInicio", ascending: false)]
    }
    
    @objc(includesQuery) static var includesQuery: [String] {
        return ["causa", "proteccion", "ubicacion", "circuito"]
    }
}

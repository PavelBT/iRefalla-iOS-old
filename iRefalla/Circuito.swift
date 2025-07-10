//
//  Circuito.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 13/06/18.
//  Copyright © 2018 Pavel Balderrama. All rights reserved.
//

import Foundation
import Parse

class Circuito: PFObject {
    @NSManaged var clave: String
    @NSManaged var nombre: String
    @NSManaged var division: String
    @NSManaged var banco: String?
    @NSManaged var zonas: [String]
    @NSManaged var area: String
    @NSManaged var longitud: Float
    @NSManaged var demanda: Float
    @NSManaged var clientes: Int
    @NSManaged var ubicacion: PFGeoPoint?
    @NSManaged var span: NSNumber?
    @NSManaged var eventos: [String : AnyObject]?
    @NSManaged var usuariosImportantes: NSNumber?
    // restablecimiento manual para evento mayor
    var restablecimientoManual: Int?
    
    func getNota(completition: @escaping (String?) -> Void) {
        let params = ["circuito": self.clave, "fecha": Date() ] as [String: AnyObject]
        PFCloud.callFunction(inBackground: "notaCircuito", withParameters: params) { (result, error) in
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

extension Circuito {
    
    var _title: String {
        let rest = restablecimientoManual != nil ? String(format: " (%i%%)", restablecimientoManual!) : ""
        let text = self.clave + rest
        return text
    }
    
    var _detalle: String {
        let bco = banco != nil ? "T\(banco!) - " : ""
        let clientesRest = restablecimientoManual != nil && restablecimientoManual != 0  ? String(format: "/%i", clientes * (restablecimientoManual!) / 100) : ""
        let text = String(format: "%@%.1f km | %i%@ clientes - %.1f MW", bco, longitud, clientes, clientesRest, demanda / 1000)
        return text
    }
    
    var _eventos: EventosCircuitos {
        return EventosCircuitos(dict: eventos)
    }
    
//    var _eventosResumen: String? {
//        return String(format: "Mes: %i/%i | Trimes: %i/%i | Año: %i/%i", _eventos.mes.permanente, _eventos.mes.transitorio, _eventos.trimestre.permanente, _eventos.trimestre.transitorio, _eventos.ano.permanente, _eventos.ano.transitorio)
//    }
    
    var _span: Double? {
        return span != nil ? Double(truncating: span!) : nil
    }
    
}

extension Circuito: PFSubclassing {
    static func parseClassName() -> String {
        return "Circuitos"
    }
}

extension Circuito: ParseManager {

    static var storePolicy: storePolicy {
        return .cache
    }
    
    static var sortDefault: [NSSortDescriptor]? {
        return [NSSortDescriptor(key: "clave", ascending: true)]
    }
}

extension Circuito: WMSManager {
    static var layerName: mapLayer {
        return .LG_RGD
    }
}

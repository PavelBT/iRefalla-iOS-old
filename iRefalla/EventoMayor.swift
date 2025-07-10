//
//  EventoMayor.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 15/01/19.
//  Copyright © 2019 Pavel Balderrama. All rights reserved.
//

import Foundation
import Parse

class EventoMayor: PFObject {
    @NSManaged var nombre: String
    @NSManaged var fechaInicio: Date
    @NSManaged var fechaFin: Date?
    @NSManaged var circuitos: [Circuito]?
    @NSManaged var registros: [PFObject]?
    @NSManaged var clientes: Int
    @NSManaged var demanda: Float
    @NSManaged var clientesRestablecidos: Int
    @NSManaged var demandaRestablecida: Float
    @NSManaged var descripcion: String
    @NSManaged var restablecimiento: Int
    @NSManaged var restablecimientoManual: [String: Int]?
    @NSManaged var usuariosImportantes: Int
    @NSManaged var duracion: Int
    @NSManaged var instalaciones: [String: Int]?
    @NSManaged var bancos: [String: [String]]?
    @NSManaged var lineas: [String]?
    
    
    
    func getNota(completition: @escaping (String?) -> Void) {
        let params = ["evento": self.objectId ] as? [String: String]
        PFCloud.callFunction(inBackground: "notaEventoMayor", withParameters: params) { (result, error) in
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

extension EventoMayor {

    var _title: String {
        let text = String(format: "%i / %i Clientes | %1.f / %1.f MW", clientes, clientesRestablecidos, demanda, demandaRestablecida)
        return text
    }
    
    var _detalle: String {
        let text = circuitos?.map {$0.clave}.joined(separator: ", ") ?? ""
        return text
    }
}

extension EventoMayor: PFSubclassing {
    static func parseClassName() -> String {
        return "EventosMayores"
    }
}

extension EventoMayor: ParseManager {
    
    static var storePolicy: storePolicy {
        return .cache
    }
    
    static var sortDefault: [NSSortDescriptor]? {
        return [NSSortDescriptor(key: "fechaIncio", ascending: false)]
    }
    
    static var includesQuery: [String] {
        return ["circuitos", "registros"]
    }
}

//
//  LineaAT.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 27/01/21.
//  Copyright © 2021 Pavel Balderrama. All rights reserved.
//

import Foundation
import Parse

class LineaAT: PFObject {
    @NSManaged var division: String
    @NSManaged var zonas: [String]
    @NSManaged var clave: String
    @NSManaged var nombre: String
    @NSManaged var voltaje: String
    @NSManaged var longitud: Float
    @NSManaged var capacidad: Int
    @NSManaged var conductor: String

}

extension LineaAT {
    var _detalle: String {
        let text = String(format: "%@ | %f.2 km - %@ | %i MVA", voltaje, longitud, conductor, capacidad)
        return text
    }
}

extension LineaAT: PFSubclassing {
    static func parseClassName() -> String {
        return "LineasAT"
    }
}

extension LineaAT: ParseManager {
    
    static var storePolicy: storePolicy {
        return .cache
    }
    
    static var sortDefault: [NSSortDescriptor]? {
        return [NSSortDescriptor(key: "clave", ascending: true)]
    }
}

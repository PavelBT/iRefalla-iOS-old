//
//  UcmEvent.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 31/08/18.
//  Copyright © 2018 Pavel Balderrama. All rights reserved.
//

import Foundation
import Parse

class UcmEvent: PFObject {
    @NSManaged var subestacion: String
    @NSManaged var equipo: String
    @NSManaged var ramal: String?
    @NSManaged var ini_timestamp: Date
    @NSManaged var proteccion: Array<String>?
    @NSManaged var fin_timestamp: Date?
    @NSManaged var tipo: String?
    @NSManaged var estado: String?
    
}

extension UcmEvent {
    
    var _text: String {
        let text = "Disparo de equipo"
        return  text
    }
    
    var _protecciones: String? {
        return proteccion?.joined(separator: " / ")
    }
    
    var _duracion: Int {
        if let fin = self.fin_timestamp {
            return Int((fin.timeIntervalSince(ini_timestamp)) / 60)
        } else {
            let dur = self.ini_timestamp.timeIntervalSinceNow
            return Int(dur / -60)
        }
    }
}

extension UcmEvent: ParseManager {

    static var storePolicy: storePolicy {
        return .onlyNetwork
    }
    
    static var sortDefault: [NSSortDescriptor]? {
        return [NSSortDescriptor(key: "ini_timestamp", ascending: false)]
    }
}
extension UcmEvent: PFSubclassing {
    static func parseClassName() -> String {
        return "EventosUCMs"
    }
}

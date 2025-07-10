//
//  Message.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 03/10/17.
//  Copyright © 2017 Pavel Balderrama. All rights reserved.
//

import Foundation
import Parse

class Mensaje: PFObject {
    
    @NSManaged var fecha: Date?
    @NSManaged var registro: RegistroCNN?
    @NSManaged var id_cnn: String?
    @NSManaged var usuario: PFUser?
    @NSManaged var userName: String?
    @NSManaged var texto: String?
    
    override init() {
        super.init()
    }
    
    init(texto: String) {
        super.init()
        self.usuario = PFUser.current()
        self.userName = PFUser.current()?.username
        self.texto = texto
        self.fecha = Date()
    }
}

extension Mensaje {
    var _fecha: Date {
        if let date = fecha {
            return date
        } else {
            return self.createdAt!
        }
    }
}
extension Mensaje: PFSubclassing {
    static func parseClassName() -> String {
        return "Mensajes"
    }
}

extension Mensaje: ParseManager {

    static var sortDefault: [NSSortDescriptor]? {
        return [NSSortDescriptor(key: "createdAt", ascending: true)]
    }
}

extension Mensaje: ParseLocalManager {
    static var storePolicy: storePolicy {
        return .cache
    }
}

//
//  Restablecimiento.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 01/11/18.
//  Copyright © 2018 Pavel Balderrama. All rights reserved.
//

import Foundation

struct Restablecimiento {
    var equipo: String?
    var fecha: Date?
    var observaciones: String?
    var porcentajeDentro: Int?
    var relevador: String?
    var usuarios: Int?
    
    init(dic: [String: AnyObject]?) {
        self.equipo = dic?["equipo"] as? String
        self.fecha = dic?["fechaHoraDisparo"] as? Date
        self.observaciones = dic?["observaciones"] as? String
        self.porcentajeDentro = dic?["porcentajeDentro"] as? Int
        self.relevador = dic?["relevador"] as? String
        self.usuarios = dic?["usuarios"] as? Int
    }
    
}

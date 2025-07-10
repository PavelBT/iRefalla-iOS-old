//
//  EstadisticaZona.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 6/7/19.
//  Copyright © 2019 Pavel Balderrama. All rights reserved.
//

import Foundation

struct EstadisticaZona: JsonToObjectProtocol {
    var zona: String
    var permantente: Int
    var transitorio: Int
    var total: Int
    
}

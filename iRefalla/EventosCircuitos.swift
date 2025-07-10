//
//  EventosCircuitos.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 1/29/19.
//  Copyright © 2019 Pavel Balderrama. All rights reserved.
//

import Foundation
import Parse

struct EventosCircuitos {
    struct evento {
        var permanente: Int = 0
        var transitorio: Int = 0
    }
    
    var circuito: String?
    var zonas: [String]?
    var mes: evento
    var trimestre: evento
    var ano: evento
    
    init(dict: Dictionary<String, AnyObject>?) {
        self.zonas = dict?["zonas"] as? [String]
        self.circuito = dict?["circuito"] as? String
        
        let mes = dict?["mes"] as? [String: Int]
        let trimestre = dict?["trimestre"] as? [String: Int]
        let ano = dict?["anoMovil"] as? [String: Int]
        self.mes = evento(permanente: mes?["permanente"] ?? 0, transitorio: mes?["transitorio"] ?? 0)
        self.trimestre = evento(permanente: trimestre?["permanente"] ?? 0, transitorio: trimestre?["transitorio"] ?? 0)
        self.ano = evento(permanente: ano?["permanente"] ?? 0, transitorio: ano?["transitorio"] ?? 0)
    }
    
    // GET TOP CIRCUITOS CON MAS EVENTOS
    enum periodoEventos: String {
        case mes, trimestre, anoMovil
    }
    
    static func getTopCircuitosEventos(limit: Int, periodo: periodoEventos, completion: @escaping ([EventosCircuitos]?) -> Void) {
        PFCloud.callFunction(inBackground: "topCircuitos", withParameters: ["limit" : limit, "periodo": periodo.rawValue]) { (data, error) in
            if error == nil, let result = data as? [Dictionary<String, AnyObject>?], result.count > 0  {
//                print(result)
                var array = [EventosCircuitos]()
                for eve in result {
                    let row = EventosCircuitos(dict: eve)
                    array.append(row)
                }
                completion(array)
            } else {
                print(error?.localizedDescription as Any)
                completion(nil)
            }
        }
    }
    
    
    static func getEventosByZonas(periodo: periodoEventos, completion: @escaping ([[String: AnyObject]]?) -> Void) {
        PFCloud.callFunction(inBackground: "EventosZonas", withParameters: ["periodo": periodo.rawValue]) { (data, error) in
            if error == nil, let result = data as? [[String: AnyObject]], result.count > 0  {
                completion(result)
            } else {
                print(error?.localizedDescription as Any)
                completion(nil)
            }
        }
    }
    
    var _eventosResumen: String {
        return String(format: "Mes: %i/%i | Trimes: %i/%i | Año: %i/%i", self.mes.permanente, self.mes.transitorio, self.trimestre.permanente, self.trimestre.transitorio, self.ano.permanente, self.ano.transitorio)
    }
    
}


//
//  Restaurador.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 07/09/18.
//  Copyright © 2018 Pavel Balderrama. All rights reserved.
//

import Foundation
import CoreLocation

struct Restaurador: WFSManager {
    var idFeature: String?
    var type: GeoJsonType?
    var coordinate: [Coordinate]?
    var id: Int?
    var division: String?
    var zona: String?
    var circuito: String?
    var marca: String?
    var tipo: String?
    var estado: String?
    var economico: String?
    var observacio: String?

}

extension Restaurador {
    
    static var layerName: mapLayer {
        return .restauradores
    }
    var annotation: MapAnnotation {
        let image = estado == "NA" ? #imageLiteral(resourceName: "restauradorNAIcon") : #imageLiteral(resourceName: "restauradorIcon")
        return MapAnnotation(title: economico, subtitle: marca, coordinate: coordinate!.first!.coordinates, image: image, draggable: false)
    }
}

//
//  Seccionador.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 21/08/20.
//  Copyright © 2020 Pavel Balderrama. All rights reserved.
//

import Foundation
import CoreLocation

struct Seccionador: WFSManager {
    var idFeature: String?
    var type: GeoJsonType?
    var coordinate: [Coordinate]?
    var id: Int?
    var division: String?
    var zona: String?
    var circuito: String?
    var vias: Int?
    var medioaisla: String?
    var economico: String?
    var observaciones: String?

}

extension Seccionador {
    
    static var layerName: mapLayer {
        return .seccionador_subt
    }
    var annotation: MapAnnotation {
        let image = #imageLiteral(resourceName: "seccionadorIcon")
        let title = economico == "" ? circuito : economico
        let viasStr = String(vias ?? 0)
        let subtitle = medioaisla ?? "" + " | " + viasStr
        return MapAnnotation(title: title, subtitle: subtitle, coordinate: coordinate!.first!.coordinates, image: image, draggable: false)
    }
}

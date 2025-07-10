//
//  Subestacion.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 23/04/17.
//  Copyright © 2017 Pavel Balderrama. All rights reserved.
//

import Foundation
import Parse
import MapKit

enum subestacionIcon: String {
    case DISTRIBUCION, TRANSMISION
    case CLIENTE = "TIPO CLIENTE"
    func getIcon() -> UIImage {
        switch self {
        case .DISTRIBUCION:
            return #imageLiteral(resourceName: "subestacionIconDistribucion")
        case .TRANSMISION:
            return #imageLiteral(resourceName: "subestacionIcon")
        case .CLIENTE:
            return #imageLiteral(resourceName: "subestacionIconCliente")
        }
    }
}

class Subestacion: PFObject {
    @NSManaged var division: String
    @NSManaged var zonas: [String]
    @NSManaged var clave: String
    @NSManaged var nombre: String
    @NSManaged var transformadores: Int
    @NSManaged var tipo: String
    @NSManaged var mva: Int
    @NSManaged var voltaje: String
    @NSManaged var ubicacion: PFGeoPoint?

}

extension Subestacion {
    var _detalle: String {
        let text = self.tipo == "TIPO CLIENTE" ? String(format: "%@", voltaje) : String(format: "%@ | %i-%i MVA", voltaje, transformadores, mva)
        return text
    }
    
    var _tipo: subestacionIcon {
        return subestacionIcon(rawValue: tipo)!
    }
    
    var annotation: MapAnnotation? {
        if let ubicacion = ubicacion {
            let ubicacion = CLLocationCoordinate2D(latitude: ubicacion.latitude, longitude: ubicacion.longitude)
            return MapAnnotation(title: clave + "-" + nombre, subtitle: _detalle, coordinate: ubicacion, image: _tipo.getIcon(), draggable: false)
        }
        return nil
    }
    
    var _mapItem: MKMapItem? {
        if let ubicacion = ubicacion {
            let place = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: ubicacion.latitude, longitude: ubicacion.longitude))
            let mapItem =  MKMapItem(placemark: place)
            mapItem.name = clave + " " + nombre
             return MKMapItem(placemark: place)
        }
        return nil
    }
}

extension Subestacion: PFSubclassing {
    static func parseClassName() -> String {
        return "Subestaciones"
    }
}

extension Subestacion: ParseManager {
    
    static var storePolicy: storePolicy {
        return .cache
    }
    
    static var sortDefault: [NSSortDescriptor]? {
        return [NSSortDescriptor(key: "clave", ascending: true)]
    }
}

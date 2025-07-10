//
//  UsuarioImportante.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 08/04/20.
//  Copyright © 2020 Pavel Balderrama. All rights reserved.
//

import Foundation
import Parse
import MapKit


class UsuarioImportante: PFObject {
    @NSManaged var division: String
    @NSManaged var zonas: String
    @NSManaged var nombre: String
    @NSManaged var direccion: String
    @NSManaged var giro: String
    @NSManaged var estado: String
    @NSManaged var municipio: String
    @NSManaged var circuito: Circuito
    @NSManaged var restaurador: String
    @NSManaged var contacto: String?
    @NSManaged var telefono: String?
    @NSManaged var ubicacion: PFGeoPoint?
    
    enum tipoUsuario: String {
        case AEROPUERTO, CENTRO_COMERCIAL, INDUSTRIAS_IMPORTANTES, GOBIERNO, OFICINAS_DE_GOBIERNO, HOSPITAL, SISTEMA_DE_AGUA_POTABLE, MILITAR, RECLUSORIO, OTRO
        func getIcon() -> UIImage? {
            switch self {
            case .HOSPITAL:
                return #imageLiteral(resourceName: "hospitalIcon")
            case .SISTEMA_DE_AGUA_POTABLE:
                return #imageLiteral(resourceName: "aguaIcon")
            default:
                return nil
            }
        }
    }
}

extension UsuarioImportante {
    
    var tipo: tipoUsuario {
        let giro = self.giro.replacingOccurrences(of: " ", with: "_").uppercased()
        return tipoUsuario(rawValue: giro) ?? .OTRO
    }
    
    var annotation: MapAnnotation? {
        if let ubicacion = ubicacion?.coordinate, let image = tipo.getIcon() {
            return MapAnnotation(title: nombre, subtitle: municipio, coordinate: ubicacion, image: image, draggable: false)
        }
        return nil
    }
    
    var _mapItem: MKMapItem? {
        if let ubicacion = ubicacion {
            let place = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: ubicacion.latitude, longitude: ubicacion.longitude))
            let mapItem =  MKMapItem(placemark: place)
            mapItem.name = nombre
             return MKMapItem(placemark: place)
        }
        return nil
    }
}

extension UsuarioImportante: PFSubclassing {
    static func parseClassName() -> String {
        return "UsuariosImportantes"
    }
}

extension UsuarioImportante: ParseManager {
    
    static var storePolicy: storePolicy {
        return .onlyNetwork
    }
    
    static var sortDefault: [NSSortDescriptor]? {
        return [NSSortDescriptor(key: "nombre", ascending: true)]
    }
}

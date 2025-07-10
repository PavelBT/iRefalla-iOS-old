//
//  Ubicacion.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 22/09/18.
//  Copyright © 2018 Pavel Balderrama. All rights reserved.
//

import Foundation
import Parse

class Ubicacion: PFObject {
    @NSManaged var id_cnn: String?
    @NSManaged var fecha: Date
    @NSManaged var userName: String?
    @NSManaged var ubicacion: PFGeoPoint
    
    override init() {
        super.init()
    }
    
    init(location: CLLocationCoordinate2D ) {
        super.init()
        self.fecha = Date()
        self.userName = currentUser?.username
        self.ubicacion = PFGeoPoint(latitude: location.latitude, longitude: location.longitude)
    }
    
}

extension Ubicacion {
    var _coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: ubicacion.latitude, longitude: ubicacion.longitude)
    }
}

extension Ubicacion: PFSubclassing {
    
    static func parseClassName() -> String {
        return "Ubicaciones"
    }
    
}

extension Ubicacion: ParseManager, ParseLocalManager {

    static var storePolicy: storePolicy {
        return .onlyNetwork
    }
    
    
    static var sortDefault: [NSSortDescriptor]? {
        return [NSSortDescriptor(key: "fecha", ascending: false)]
    }
    
}



//
//  Division.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 28/Sep/22.
//  Copyright © 2022 Pavel Balderrama. All rights reserved.
//

import Foundation
import Parse

class Division: PFObject {
    @NSManaged var clave: String
    @NSManaged var nombre: String
    @NSManaged var ubicacion: PFGeoPoint?
    @NSManaged var span: NSNumber?
}

extension Division: PFSubclassing {
    static func parseClassName() -> String {
        return "Divisiones"
    }
}

extension Division: ParseManager, ParseLocalManager {

    static var storePolicy: storePolicy {
        return .localIfNeedsUpdate
    }
    
    static var sortDefault: [NSSortDescriptor]? {
        return [NSSortDescriptor(key: "clave", ascending: true)]
    }
}

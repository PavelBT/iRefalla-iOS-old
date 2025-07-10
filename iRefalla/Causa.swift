//
//  Causa.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 23/04/17.
//  Copyright © 2017 Pavel Balderrama. All rights reserved.
//

import Foundation
import Parse

class Causa: PFObject {
    @NSManaged var clave: String?
    @NSManaged var nombre: String?
}

extension Causa: PFSubclassing {
    static func parseClassName() -> String {
        return "Causas"
    }
}

extension Causa: ParseManager, ParseLocalManager {

    static var storePolicy: storePolicy {
        return .localIfNeedsUpdate
    }
    
    static var sortDefault: [NSSortDescriptor]? {
        return [NSSortDescriptor(key: "clave", ascending: true)]
    }
}

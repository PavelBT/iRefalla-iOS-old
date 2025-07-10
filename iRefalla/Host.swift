//
//  Host.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 27/11/18.
//  Copyright © 2018 Pavel Balderrama. All rights reserved.
//

import Foundation

struct Host {
    let hostid: String?
    let host: String?
    let name: String?
    let status: String?
    let triggers: String?
}

extension Host: ZabbixManager {
    static var baseParams: Dictionary<String, Any> {
        return ["output": ["hostid", "host", "name", "status"], "selectTriggers": "count"]
    }
    
    static var sortOrder: [String] {
        return ["name"]
    }
    
    static var getMethod: String {
        return "host.get"
    }

}

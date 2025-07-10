//
//  Trigger.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 30/11/18.
//  Copyright © 2018 Pavel Balderrama. All rights reserved.
//

import Foundation

struct Trigger {
    let triggerid: String?
    let hosts: [Host]?
    let description: String?
    let priority: String?
    let lastchange: String?
    let comments: String
    let value: String?
}

extension Trigger {
    var _fecha: Date  {
        let interval = Double(lastchange ?? "0")
        let date = Date(timeIntervalSince1970: interval!)
        return date
    }
}

extension Trigger: ZabbixManager {
    static var baseParams: Dictionary<String, Any> {
        return ["output": ["triggerid", "description", "priority", "lastchange", "comments", "value"], "selectHosts": ["hostid", "host", "name", "status"],"sortorder": "DESC", "min_severity": 4]
    }
    
    static var sortOrder: [String] {
        return ["lastchange"]
    }
    
    static var getMethod: String {
        return "trigger.get"
    }
    
    
}

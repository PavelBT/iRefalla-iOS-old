//
//  HostGroup.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 27/11/18.
//  Copyright © 2018 Pavel Balderrama. All rights reserved.
//

import Foundation

struct HostGroup {
    var groupid: String?
    var name: String?
    var hosts: String?
}

extension HostGroup: ZabbixManager {
    static var getMethod: String {
        return "hostgroup.get"
    }
    
    static var baseParams: Dictionary<String, Any> {
        return ["real_hosts": 1, "selectHosts": "count"]
    }
    
    static var sortOrder: [String] {
        return ["name"]
    }
    

}

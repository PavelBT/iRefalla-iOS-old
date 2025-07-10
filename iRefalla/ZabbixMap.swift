//
//  ZabbixMap.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 03/12/18.
//  Copyright © 2018 Pavel Balderrama. All rights reserved.
//

import Foundation

struct ZabbixMap {
    let sysmapid: String?
    let name: String?
//    let urls: [String]?
    let height: String?
    let width: String?
//    let links: [Link]?
//    let selements: [Element]?
//    
//    // elementos en el mapa
//    struct Element: Decodable {
//        let elementtype: String?
//        let label: String?
//        let selementid: String?
//        let x: String?
//        let y: String?
//        let iconid_off: String?
//        let iconid_on: String?
//        let width: String?
//    }
//    
//    // enalces entre elementos
//    struct Link: Decodable {
//        let drawtype: String?
//        let linkid: String?
//        let selementid1: String?
//        let selementid2: String?
//    }
}

extension ZabbixMap: ZabbixManager {
    static var baseParams: Dictionary<String, Any> {
        return ["selectUrls": ["sysmapurlid", "name", "url"]]
    }
    
    static var sortOrder: [String] {
        return ["name"]
    }
    
    static var getMethod: String {
        return "map.get"
    }
    
}

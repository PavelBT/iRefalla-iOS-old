//
//  GeoserverManager.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 07/09/18.
//  Copyright © 2018 Pavel Balderrama. All rights reserved.
//

import Foundation
import Alamofire

let geoURL = "https://apps.vmn.cfe.mx/geoserver"
//let geoURL = "http://10.59.20.29:2001/geoserver" // local server ip

enum mapLayer: String, EnumCollection {
    case Default, LG_RGD, DVMN, restauradores, seccionador_subt, Usuarios_Importantes, Base2
    case GeoSol = "daestro_geo"
}

enum GeoService: String {
    case wms, wfs, tms
}

enum GeoJsonType: String, Decodable {
    case Point, LineString, Polygon
}

protocol GeoserverManager {
    static var layerName: mapLayer {get}
    static var service: GeoService {get}
    static var version: String {get}
    static var epsg: String {get}
    static func getCapabilities(layers: @escaping ([String]?) -> Void)
}

extension GeoserverManager {
    static var baseURL: String {
        return geoURL + "/" + service.rawValue + "?service=\(service.rawValue)&version=\(Self.version)"
    }
    
    // WMS services
    static var serviceURL: String {
        var referenceSystem = ""
        if version == "1.1.1" {
            referenceSystem = "SRS"
        } else {
            referenceSystem = "CRS"
        }
        let req = service == .wms ? "GetMap" : "GetFeature"
        let urlReferenceSystem = service == .wms ? "\(referenceSystem)=EPSG:\(epsg)&" : "srsName=EPSG:\(epsg)"
        return baseURL + "&request=\(req)&\(urlReferenceSystem)"
    }
    
    static func getCapabilities(layers: @escaping ([String]?) -> Void) {
        let urlString = baseURL + "&request=GetCapabilities"
        Alamofire.request(urlString).validate()
            .responseData { (response) in
                switch response.result {
                case .success(let data):
                    let parse = XMLParseHandler()
                    parse.parseLayer(data: data, completion: { (results) in
                        layers(results)
                    })
                case .failure(let error):
                    print(error.localizedDescription)
                }
        }
    }
    
}


//
//  WFSManager.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 11/09/18.
//  Copyright © 2018 Pavel Balderrama. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import CoreLocation

protocol WFSManager: GeoserverManager, Decodable {
    var idFeature: String? {get set}
    var type: GeoJsonType? {get set}
    var coordinate: [Coordinate]? {get set}
}

extension WFSManager {
    
    static var service: GeoService {
        return .wfs
    }
    static var version: String {
        return "2.0.0"
    }
    
    static var epsg: String {
        return "4326"
    }
    
    private mutating func setCoords(coordinates: [AnyObject]) {
        switch type! {
        case .Point:
            let coords = coordinates as! [Double]
            self.coordinate = [Coordinate(lat: coords[1], long: coords[0])]
        default:
            break
        }
    }
    
    static func getFeatures(filter: String?, completion: @escaping ([Self]?) -> Void) {
        let filterStr = filter != nil ? "cql_filter=" + filter! : ""
        let url = Self.serviceURL + "&typeNames=\(Self.layerName)&\(filterStr)&outputFormat=application/json"
        var array = [Self]()
        Alamofire.request(url)
            .validate()
            .responseData { (response) in
                switch response.result {
                case .success(let data):
                    let json = JSON(data)
                    let features = json["features"].arrayValue
                    let crs = json["crs"]
                    let type = json["type"].stringValue
                    let totalFeatures = json["totalFeatures"].intValue
                    print("Total: \(totalFeatures) \nTipo: \(type)\nCRS: \(crs)")
                    let decode = JSONDecoder()
                    
                    do{
                        for rowJson in features {
                            let properties = try JSON(rowJson["properties"]).rawData()
                            var row = try decode.decode(Self.self, from: properties)
                            row.idFeature = rowJson["id"].stringValue
                            row.type = GeoJsonType(rawValue: rowJson["geometry"]["type"].stringValue)
                            let coordinate = rowJson["geometry"]["coordinates"].arrayObject! as [AnyObject]
                            row.setCoords(coordinates: coordinate)
                            array.append(row)
                        }
                        completion(array)
                    } catch {
                        print("error al decodificar: Error: \(error.localizedDescription)")
                        completion(nil)
                    }
                case .failure(let error):
                    print(error)
                }
        }
    }
}


// COORDENADAS
struct Coordinate: Decodable {
    var lat: Double
    var long: Double
}

extension Coordinate {
    var coordinates: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.lat, longitude: self.long)
    }
}

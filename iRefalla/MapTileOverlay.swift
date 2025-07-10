//
//  mapTileOverlay.swift
//  UCM App
//
//  Created by Pavel Balderrama on 16/03/18.
//  Copyright © 2018 Pavel Balderrama. All rights reserved.
//

import Foundation
import MapKit

class MapTileOverlay: MKTileOverlay {
    
    var layer: mapLayer!
    let db = "sigedvmn"
    
    override func url(forTilePath path: MKTileOverlayPath) -> URL {
        let yDec =  pow(2, path.z) - Decimal(path.y) - 1
        let y = Int(truncating: NSDecimalNumber(decimal: yDec))
        let template = geoURL + "/gwc/service/tms/1.0.0/\(db):\(layer.rawValue)@EPSG:900913@png/\(path.z)/\(path.x)/\(y).png"
        return URL(string: template)!
    }
    
    override func loadTile(at path: MKTileOverlayPath, result: @escaping (Data?, Error?) -> Void) {
        let urlTile = url(forTilePath: path)
            let request = URLRequest(url: urlTile)
            URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                if error == nil, let data = data {
                    return result(data, nil)
                } else {
                    return result(nil, error)
                }
            }).resume()
    }
    
    static func loadOverlays(layers: [mapLayer]) -> [MapTileOverlay] {
        var result = [MapTileOverlay]()
        for layer in layers {
            let overlay = MapTileOverlay()
            overlay.minimumZ = 0
            overlay.maximumZ = 30
            overlay.layer = layer
            result.append(overlay)
        }
        return result
    }
}

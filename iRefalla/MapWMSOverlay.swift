//
//  MapWMSOverlay.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 21/05/18.
//  Copyright © 2018 Pavel Balderrama. All rights reserved.
//

import Foundation
import WMSKit
import MapKit

struct WebMapServiceConstants {
    static let baseUrl = "https://openwms.statkart.no/skwms1/wms.kartdata2"
    static let version = "1.3.0"
    static let epsg = "4326"
    static let format = "image/png"
    static let tileSize = "256"
    static let transparent = true
}

class WMSServices {
    

    
    func getLayers() {
        let urlString = WebMapServiceConstants.baseUrl + "?request=GetCapabilities&Service=WMS"
        
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with:url!) { (data, response, error) in
            if error != nil {
                print(error as Any)
            } else {
                
                let parser = XMLParser(data: data!)
//                parser.delegate = self
                let success = parser.parse()
                
                if success {
                    print(parser)
                } else {
                    print("parse failure!")
                }
            }
            }.resume()
    }

}

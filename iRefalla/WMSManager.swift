//
//  WMSManager.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 11/09/18.
//  Copyright © 2018 Pavel Balderrama. All rights reserved.
//

import Foundation

protocol WMSManager: GeoserverManager {
    static var format: String {get}
    static var tileSize: String {get}
    static var opacity: CGFloat? {get}
}

extension WMSManager  {
    
    static var db: String {
        return "sigedvmn"
    }
    static var format: String {
        return "image/png"
    }
    
    static var tileSize: String {
        return "256"
    }
    
    static var opacity: CGFloat? {
        return nil
    }
    
    static var service: GeoService {
        return .wms
    }
    
    static var version: String {
        return "1.3.0"
    }
    
    static var epsg: String {
        return "4326"
    }
    
    
    static func getWMSLayer(layer: mapLayer = layerName, filter: String? = nil, style: String? = nil) -> WMSTileOverlay {
        
        let urlLayers = "layers=\(db):\(layer.rawValue)&"
        let urlStyle = style == nil ? "" : "styles=" + style! + "&"
        let urlWidthAndHeight = "width=\(tileSize)&height=\(tileSize)&"
        let urlFormat = "format=\(format)&"
        let urlTransparent = "transparent=true&"
        let urlFilter = filter == nil ? "" : "CQL_FILTER=" + filter!
        
        let urlString = self.serviceURL + "&"  + urlLayers + urlStyle  + urlWidthAndHeight + urlFormat + urlTransparent + urlFilter
        var useMercator = false
        if(epsg == "900913"){
            useMercator = true
        }
        let overlay = WMSTileOverlay(urlArg: urlString, useMercator: useMercator, wmsVersion: version)
        
        overlay.alpha = opacity ?? 1
        overlay.canReplaceMapContent = false
        
        return overlay
    }
}

//
//  FallaAnnotation.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 14/06/18.
//  Copyright © 2018 Pavel Balderrama. All rights reserved.
//

import Foundation
import MapKit

class FallaAnnotation: MapAnnotation {
    
    init(title: String?, subtitle: String?, coordinate: CLLocationCoordinate2D) {
        super.init(title: title, subtitle: subtitle, coordinate: coordinate, image: #imageLiteral(resourceName: "alertIcon"), draggable: true)
    }
}

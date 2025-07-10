//
//  MapAnnotation.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 10/09/18.
//  Copyright © 2018 Pavel Balderrama. All rights reserved.
//

import Foundation
import MapKit

enum AnnotationButton {
    case system(UIButton.ButtonType), custom(UIImage)
    
    func getButton() -> UIButton {
        switch self {
        case .system(let type):
            return UIButton(type: type)
        case .custom(let type):
            let button = UIButton(type: .custom)
            button.frame = CGRect(x: 5, y: 5, width: 20, height: 30)
            button.setImage(type, for: .normal)
            return button
        }
    }
}

class MapAnnotation: NSObject, MKAnnotation {
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    var image: UIImage
    var draggable: Bool
    var button: AnnotationButton? {
         return draggable ? AnnotationButton.system(.contactAdd) : AnnotationButton.system(.detailDisclosure)
    }
    
    init(title: String?, subtitle: String?, coordinate: CLLocationCoordinate2D, image: UIImage, draggable: Bool) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.image = image
        self.draggable = draggable

    }
}

extension MapAnnotation {
    var view: MKAnnotationView {
        let view = MKAnnotationView(annotation: self , reuseIdentifier: title)
        view.image = self.image
        view.frame.size = CGSize(width: 25, height: 25)
        // detail callout
        view.canShowCallout = true
        view.calloutOffset = CGPoint(x: -5, y: 5)
        view.rightCalloutAccessoryView = button?.getButton()
        view.isDraggable = self.draggable
        
        return view
    }
    
    var mapItem: MKMapItem {
        let place = MKPlacemark(coordinate: self.coordinate)
        let mapItem = MKMapItem(placemark: place)
        return mapItem
    }
}

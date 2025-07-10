//
//  MapTilesViewController.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 17/05/18.
//  Copyright © 2018 Pavel Balderrama. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation
import MRProgress
import WebKit
import Parse

fileprivate let precisionCentrar: Double = 200
fileprivate let precisionAgregar: Double = 100

class MapTilesViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var controlsContainer: UIView!
    @IBOutlet weak var mapOptionView: UIView!
    
    private var currentLayers: [mapLayer]?
    private var currentOverlays: [MapTileOverlay]?
    private var layers = [WMSTileOverlay]()
    private var mapRect = MKMapRect.null
    private var cache = URLCache(memoryCapacity: 100*1024*1024, diskCapacity: 500*1024*1024, diskPath: "mapTileCache")

    private let locationManager = CLLocationManager()
    private var resultSearchController:UISearchController? = nil
    private var leftButton: UIBarButtonItem?
    var circuitos: [String]?
    var fallasAnnotation: [FallaAnnotation]?
    var addLocation: Bool = false
    var isLoadFirstTime: Bool = true
    private var tap: UITapGestureRecognizer!
    var annotation: MKAnnotation?
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Mapa RGD"
        URLCache.shared = cache
//        cache.removeAllCachedResponses()
//        cache.diskCapacity = 0
//        cache.memoryCapacity = 0
        
        print("Cache used: \(cache.currentDiskUsage)")
        
        mapView.delegate = self
        mapView.showsUserLocation = addLocation
        mapView.layoutMargins = UIEdgeInsets(top: 100, left: 0, bottom: 0, right: 0) // margin for compass
        
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        leftButton = UIBarButtonItem(title: "Cancelar", style: .plain, target: self, action: #selector(dismissView))
        navigationItem.leftBarButtonItem = leftButton
        
        // Configure view container
        controlsContainer.layer.cornerRadius = 10
        mapOptionView.layer.cornerRadius = 10
        
        // LOAD LAYERS
        loadLayers()
        
        loadSearchBar()
        
        tap = UITapGestureRecognizer(target: self, action: #selector(self.mapOptions(_:)))
        
        if let annotation = annotation {
            self.mapView?.showAnnotations([annotation], animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // ocultar mapOption
        let y = self.getBoundHeigth()
        self.mapOptionView.frame.origin.y = y
    }
    
    @objc func dismissView () {
//        self.delegate = nil
//        self.mapView.delegate = nil
//        self.resultSearchController?.delegate = nil
        Ubicacion.unPinAllLabel(label: newItemsLabel)
        dismiss(animated: true, completion: nil)
    }
    
    private func loadLayers() {
        // obeter las cordenadas para la region del mapa, a traves de una funcion cloud
        if let falla = fallasAnnotation {
            mapView.showAnnotations(falla, animated: true)
        } else if let currentUser = currentUserData, let div = currentUser.value(forKey: "division") as? String {
            Division.getByClave(clave: div) { division in
                let cords = (division?.ubicacion as? PFGeoPoint) ?? PFGeoPoint(latitude: 19.7, longitude: -99.12)
                let span = Double(truncating: division?.span ?? 0.6)
                let center = CLLocationCoordinate2D(latitude: cords.latitude, longitude: cords.longitude)
                let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: span, longitudeDelta: span))
                self.mapView.setRegion(region, animated: true)
            }
        }
        // add DVMN TITLES overlays
        currentLayers = [.Default]
        currentOverlays = MapTileOverlay.loadOverlays(layers: currentLayers!)
        mapView.addOverlays(currentOverlays!, level: .aboveRoads)
        
        // load RGD map over WMS
        let redWMS = Circuito.getWMSLayer(layer: .LG_RGD)
        layers.append(redWMS)
        
        // Load Circuitos
        loadCircuitosWMS(circuitos: circuitos)
        
        //load Subestaciones
        Subestacion.getAll { (subestacionesData) in
            let data = subestacionesData?.map {$0.annotation}.filter {return $0 != nil}
            if let annotations = data as? [MKAnnotation] {
                self.mapView.addAnnotations(annotations)
            }
        }
    }
    
    private func loadCircuitosWMS(circuitos: [String]?) {
        if let circuitos = circuitos {
            let circuitosUnique = Array(Set(circuitos))
            for circuito in circuitosUnique {
                let circuito = circuito.replacingOccurrences(of: "-", with: "") // remove -
                let filter = "circuito='\(circuito)'"
                
                // no dibuja la linea por que se agrego la capa LD_RGD con toda la red
//                let style = "STY_RGD_bold"
//                let cirLayer = Circuito.getWMSLayer(filter: filter, style: style)
//                layers.append(cirLayer)
                
                Restaurador.getFeatures(filter: filter) { results in
                    if let annotations = results?.map({$0.annotation}) {
                            self.mapView.addAnnotations(annotations)
                    }
                }
                
                Seccionador.getFeatures(filter: filter) { results in
                    if let annotations = results?.map({$0.annotation}) {
                            self.mapView.addAnnotations(annotations)
                    }
                }
            }
            mapView.addOverlays(layers, level: .aboveRoads)
            setVisibleMap(circuitos: circuitosUnique)
        } else {
            // para agregar las capas
            mapView.addOverlays(layers, level: .aboveRoads)
        }
    }
    
    private func setVisibleMap (circuitos circuitosFilter: [String]) {
        Circuito.getAll(limit: 1000) { (circuitos) in
            if let circuitos = circuitos, circuitos.count > 0 {
                let cirFilter = circuitos.filter {return circuitosFilter.contains($0.clave)}
                if cirFilter.count == 1, let ubicacion = cirFilter.first?.ubicacion {
                    let location = CLLocationCoordinate2D(latitude: ubicacion.latitude, longitude: ubicacion.longitude)
                    let spanNum =  cirFilter.first?._span ?? 0.2
                    let span = MKCoordinateSpan(latitudeDelta: spanNum, longitudeDelta: spanNum)
                    let region = MKCoordinateRegion(center: location, span: span)
                    self.mapView.setRegion(region, animated: true)
                } else {
                    let lats = cirFilter.map {$0.ubicacion?.latitude}.filter {$0 != nil} as? [Double]
                    let lons = cirFilter.map {$0.ubicacion?.longitude}.filter {$0 != nil}  as? [Double]
                    if let latMax = lats?.max(), let latMin = lats?.min(), let lonMax = lons?.min(), let lonMin = lons?.max() {
                        let location = CLLocationCoordinate2D(latitude: (latMax+latMin)/2, longitude: (lonMax+lonMin)/2)
                        let span = MKCoordinateSpan(latitudeDelta: latMax-latMin+0.05, longitudeDelta: abs(lonMax-lonMin)+0.05)
                        let region = MKCoordinateRegion(center: location, span: span)
                        self.mapView.setRegion(region, animated: true)
                    }
                }
            }
        }
    }
    
    private func layerChanges(layer: mapLayer) {
        
        if currentLayers?.contains(layer) ?? false {
            let removeOverlay = currentOverlays?.filter {$0.layer == layer}
            let index = currentLayers?.index(of: layer)
            mapView.removeOverlays(removeOverlay!)
            currentLayers?.remove(at: index!)
            currentOverlays?.remove(at: index!)
        } else {
            let addOverlays = MapTileOverlay.loadOverlays(layers: [layer])
            mapView.addOverlays(addOverlays)
            currentLayers?.append(layer)
            currentOverlays?.append(addOverlays[0])
        }
    }
    
  
    // CARGA EL SEARCH BAR
    
    private func loadSearchBar() {
        weak var locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as? LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Buscar Lugar"
        searchBar.delegate = self
        self.navigationItem.titleView = resultSearchController?.searchBar
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        locationSearchTable?.mapView = mapView
        locationSearchTable?.handleMapSearchDelegate = self
        self.definesPresentationContext = true
    }
    
    
    @IBAction func mapOptions(_ sender: UIButton) {
        let frame = mapOptionView.frame
        let screenHeigth = getBoundHeigth()
        let padding:CGFloat = 36
        let naviHeigth = navigationController?.navigationBar.bounds.height ?? 0
        var y: CGFloat = 0
        if frame.origin.y == screenHeigth {
            y = screenHeigth - frame.height - padding - naviHeigth // show the view
//            menuFloatButton.isHidden = true // hide menu float button
            // tap out
            self.view.addGestureRecognizer(tap)
        } else {
            y = screenHeigth // hide de view
//            menuFloatButton.isHidden = false
            self.view.removeGestureRecognizer(tap)
        }
        UIView.animate(withDuration: 0.5) {
            self.mapOptionView.frame.origin.y = y
        }
    }
    
    private func getBoundHeigth() -> CGFloat {
        return UIScreen.main.bounds.height
    }
    
    func addFallaLocation(coordinate: CLLocationCoordinate2D) {
        if let falla = fallasAnnotation {
            mapView.removeAnnotations(falla)
        }
        let annotation = FallaAnnotation(title: "Ubicacion de falla", subtitle: "presiona (+) para agregar", coordinate: coordinate)
        fallasAnnotation = [annotation]
        self.mapView.addAnnotation(annotation)
        self.mapView.selectAnnotation(annotation, animated: false)
    }
    
    @IBAction func mapStyleSelector(_ sender: Any) {
        let mapType = (sender as! UISegmentedControl).selectedSegmentIndex
        switch mapType {
        case 1 :
            mapView.mapType = .satellite
        case 2:
            mapView.mapType = .hybrid
        default:
            mapView.mapType = .standard
        }
    }
    
    @IBAction func layersSwitch(_ sender: UISwitch) {
        var layer: mapLayer?
        
        switch sender.tag {
        case 0:
            layer = .LG_RGD
        case 1:
            layer = .Usuarios_Importantes
        default:
            break
        }
        layerChanges(layer: layer!)
    }
    
    
    @IBAction func centerLocationButton(_ sender: UIButton) {
        if mapView.userTrackingMode == .none {
            mapView.setUserTrackingMode(.followWithHeading, animated: true)
        } else {
            mapView.setUserTrackingMode(.none, animated: true)
        }
    }
    
    private func zonaByPoint(coord: CLLocationCoordinate2D) {
        let parameters = ["lat": coord.latitude, "lon": coord.longitude]
        PFCloud.callFunction(inBackground: "zonaByPoint", withParameters: parameters) { (data, error) in
            if error == nil, let data = data as? [String: Any] {
                print(data)
                let div = data["cvediv"] ?? ""
                let zona = data["cvezon"] ?? ""
                AlertDialog.ShowAlert(viewController: self, title: "Zona", message: "Div: \(div), Zona: \(zona)", completion: nil)
            } else {
                print(error?.localizedDescription as Any)
            }
        }
    }
    @IBAction func showZona(_ sender: Any) {
        if let userLoc = mapView?.userLocation.coordinate, mapView.isUserLocationVisible {
            zonaByPoint(coord: userLoc)
        }
    }
}

extension MapTilesViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let isLocate1 = userLocation.location!.horizontalAccuracy > precisionCentrar
        let isLocate2 = userLocation.location!.horizontalAccuracy <= precisionAgregar
       
        if userLocation.isUpdating, isLocate1 || self.isLoadFirstTime {
            let region = MKCoordinateRegion(center: userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            mapView.setRegion(region, animated: true)
            self.isLoadFirstTime = false
            
        }
        // add falla location
        if userLocation.isUpdating, isLocate2, addLocation {
            addFallaLocation(coordinate: userLocation.coordinate)
            self.mapView.showsUserLocation = false
//            self.dismissActivityIndicator()
        }
        
        if isLocate1, !addLocation {
//            self.dismissActivityIndicator()
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? MapAnnotation {
            annotation.draggable = addLocation
            return annotation.view
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        return MKTileOverlayRenderer(overlay: overlay)
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        switch newState {
        case .starting:
            view.dragState = .dragging
        case .ending, .canceling:
            view.dragState = .none
        //print("Nuevas Coordendas \(String(describing: view.annotation?.coordinate))")
        default: break
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let annotation = view.annotation as? FallaAnnotation, annotation.draggable { // cambiar coordenadas de falla
            // save in pin
            Ubicacion.unPinAllLabel(label: newItemsLabel)
            let ubicacion = Ubicacion(location: annotation.coordinate)
            ubicacion.pinLabel(label: newItemsLabel)
            
            self.dismiss(animated: false, completion: nil)
        } else if let annotation = view.annotation as? MapAnnotation { // restaurador
            let options = [MKLaunchOptionsDirectionsModeKey:
                MKLaunchOptionsDirectionsModeDriving,
                           MKLaunchOptionsShowsTrafficKey: true] as [String : Any]
            annotation.mapItem.openInMaps(launchOptions: options)
        }
    }
    
}


extension MapTilesViewController: HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark) {
        if !addLocation {
            let annotation = MKPointAnnotation()
            annotation.coordinate = placemark.coordinate
            annotation.title = placemark.name
            self.mapView.addAnnotation(annotation)
            zonaByPoint(coord: placemark.coordinate)
        } else {
            self.addFallaLocation(coordinate: placemark.coordinate)
        }
        self.mapView.setRegion(MKCoordinateRegion(center: placemark.coordinate, span: MKCoordinateSpan.init(latitudeDelta: 0.02, longitudeDelta: 0.02)), animated: true)
    }
}

extension MapTilesViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.navigationItem.leftBarButtonItem = nil
    }
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        self.navigationItem.leftBarButtonItem = leftButton
        return true
    }
}

//
//  ParseManager.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 05/06/18.
//  Copyright © 2018 Pavel Balderrama. All rights reserved.
//

import Foundation
import Parse

fileprivate let defaultLimit = 100
fileprivate let localStoreLimit = 2000

typealias queryParams = (field: String, value: Any?, function: queryFunc)
enum queryFunc {
    case equal, notEqual, greaterThan, lessThan, contains
}

protocol ParseManager: PFSubclassing, ParseLocalManager where Self: PFObject {
    static var sortDefault: [NSSortDescriptor]? {get}
    static var includesQuery: [String] {get}
}

extension ParseManager where Self: PFObject {
    
    static var includesQuery: [String] {
        return [String]()
    }
    
    static func getAll(limit: Int = defaultLimit,page: Int = 0, order: [NSSortDescriptor]? = sortDefault, forceServer: Bool = false, completition: @escaping ([Self]?) -> Void) {
        getFilter(limit: limit,page: page, filter: nil, order: order, forceServer: forceServer) { (data) in
            completition(data)
        }
    }
    
    static func getByClave(clave: String, completition: @escaping (Self?) -> Void) {
        getFilter(limit: 1, filter: [("clave", clave, .equal)]) { (data) in
            if let data = data, !data.isEmpty {
                completition(data[0])
            } else {
                completition(nil)
            }
        }
    }
    
    
    static func getByID(id: String, completition: @escaping (Self?) -> Void) {
        getFilter(limit: 1, filter: [("objectId", id, .equal)]) { (data) in
            if let data = data, !data.isEmpty {
                completition(data[0])
            } else {
                completition(nil)
            }
        }
    }
    
    // get pages
    static func getFilter(limit: Int = defaultLimit, page: Int = 0, filter: [queryParams]?, order: [NSSortDescriptor]? = sortDefault, forceServer: Bool = false, completition: @escaping ([Self]?) -> Void ) {

        let query = getQuery(filter: filter)
        query.limit = limit
        query.order(by:order)
        query.skip = page*limit
        
        if getLocal && !forceServer {
            query.fromLocalDatastore()
        }
        
        Self.findObjectByQuery(query: query) { (objects) in
            if let objs = objects, objs.count > 0 {
                //print(objects)
                if storePolicy == .cache {
                    cacheHandler(objects: objs)
                }
                completition(objs)
            } else if objects?.count == 0, getLocal { // no tiene datos locales
                let query2 = getQuery(filter: filter)
                query2.limit = 2000
                query2.order(by:order)
                findObjectByQuery(query: query2, completition: { (objs) in
                    completition(objs)
                })
            } else {
                completition(nil)
            }
        }
    }
    
    static private func findObjectByQuery(query: PFQuery<PFObject>, completition: @escaping ([Self]?) -> Void) {
        
        query.findObjectsInBackground(block: { (objects, error) in
            if error == nil {
                completition(objects as? [Self])
            } else {
                let error = error! as NSError
                // no internet connections, get cache
                if error.code == 100, !getLocal {
                    query.fromLocalDatastore()
                    Self.findObjectByQuery(query: query, completition: { (data) in
                        completition(data)
                    })
                } else {
                    completition(nil)
                }
                showError(error: error)
            }
        })
    }
    
    static func getQuery (filter: [queryParams]?) -> PFQuery<PFObject> {
        let query = PFQuery(className: Self.parseClassName())
        query.includeKeys(includesQuery) // include fields
        
        if let filtros = filter {
            for (field, value, function) in filtros {
                switch function {
                case .equal:
                    query.whereKey(field, equalTo: value as Any)
                case .notEqual:
                    query.whereKey(field, notEqualTo: value as Any)
                case .greaterThan:
                    query.whereKey(field, greaterThan: value as Any)
                case .lessThan:
                    query.whereKey(field, lessThan: value as Any)
                case .contains:
                    query.whereKey(field, contains: value as? String)
                }
            }
        }
        return query
    }
    
    static func showError(error: NSError) {
        let controller = currentController.topMostViewController().self
        AlertDialog.ShowAlert(viewController: controller, title: "Error", message: error.localizedDescription) { (_) in
            // Error de token code 209
            if error.code == 209 {
                GlobalMainQueue.async {
                    PFUser.logOut()
                    controller.performSegue(withIdentifier: "returnLogin", sender: nil)
                }
            }
        }
    }
    
    static fileprivate var currentController: UIViewController {
        get {
            let window = UIApplication.shared.keyWindow
            var controller = UIViewController()
            controller = (window?.rootViewController!.presentedViewController)!
            return controller
        }
    }
}

extension PFGeoPoint {
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
}

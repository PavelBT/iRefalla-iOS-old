//
//  ParseLocalManager.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 18/09/18.
//  Copyright © 2018 Pavel Balderrama. All rights reserved.
//

import Foundation
import Parse
import Alamofire

fileprivate let cacheLimit = 200

enum storePolicy: Equatable  {
    case onlyLocal, onlyNetwork, cache, localIfNeedsUpdate
}
protocol ParseLocalManager {
    static var storePolicy: storePolicy {get}
}

extension ParseLocalManager where Self: ParseManager & PFSubclassing {
    
    func pinLabel(label: String) {
        Self.pinAllLabel(objects: [self], label: label)
    }
    
    func unpinLabel(label: String) {
        do {
            try self.unpin(withName: label)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    static func getLocalLabel(label: String) -> [Self] {
        let query = PFQuery(className: Self.parseClassName())
        query.fromPin(withName: label)
        do {
            let objects = try query.findObjects() as? [Self]
            return objects ?? [Self]()
        } catch let error {
            print(error.localizedDescription)
        }
        return [Self]()
    }
    
    static func pinAllLabel(objects: [Self], label: String) {
        do {
            try PFObject.pinAll(objects, withName: label)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    static func unPinAllLabel(label: String) {
        do {
            try PFObject.unpinAllObjects(withName: label)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    static var getLocal: Bool {
        let cacheNeeded: Bool = !NetworkReachabilityManager()!.isReachable && storePolicy == .cache
        let local: [storePolicy] = [.onlyLocal, .localIfNeedsUpdate]
        return local.contains {$0 == storePolicy} || cacheNeeded
    }
    
    static func pinAllLocalData(objects: [Self]) {
        Self.pinAll(inBackground: objects, block: { (sucess, error2) in
            if error2 == nil {
                print("pin ok para la clase ", Self.description())
            } else {
                print(error2?.localizedDescription as Any)
            }
        })
//        Self.unpinAllObjectsInBackground { (success, error) in
//            if error == nil {
//                
//            } else {
//                print(error?.localizedDescription as Any)
//            }
//        }
    }
    
    
    static func cacheHandler(objects: [Self]) {
        Self.unPinAllLabel(label: "CACHE")
        Self.pinAllLabel(objects: objects, label: "CACHE")
    }
    
    static func updateLocalDB(success: @escaping (Bool) -> Void) {
        Self.getAll(limit: 2000, forceServer: true) { (data) in
            if let data = data, data.count > 0 {
                Self.pinAllLocalData(objects: data)
                success(true)
            } else {
                success(false)
            }
        }
    }
}

//
//  ZabbixManager.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 27/11/18.
//  Copyright © 2018 Pavel Balderrama. All rights reserved.
//

import Foundation
import Alamofire

struct ZabbixServer {
    static let baseUrl: String = "http://10.59.144.93:10052/zabbix"
    static let url: String = "http://10.59.144.93:10052/zabbix/api_jsonrpc.php"
    static let user: String = "Admin"
    static let password: String = "zabbix"
    static var token: String? = nil
    static var id: Int = 0
}

protocol ZabbixManager: Decodable {
    static var baseParams: Dictionary<String, Any> {get}
    static var sortOrder: [String] {get}
    static var getMethod: String {get}
}

extension ZabbixManager {
    
    // GET FUNCTIONS
    
    static func getData(filter: [String: Any]? = nil, limit: Int? = nil,completion: @escaping ([Self]?) -> Void) {
        var params = baseParams
        let sortArr = ["sortfield": sortOrder]
        let limitArr = limit != nil ? ["limit": limit!] as [String: Any] : [:]
        let filterArr = filter ?? [:]
        params.update(other: sortArr)
        params.update(other: limitArr)
        params.update(other: filterArr as Dictionary<String, Any>)
        
        request(method: getMethod, params: params) { results in
            completion(results)
        }
    }
    
    // AUXILIARY FUNCTIONS
    static private func request(method: String, params: Parameters?, completion: @escaping ([Self]?) -> Void) {
        getJSONData(method: method, params: params) { (results) in
//            print(results as Any)
            if let result = results as? [[String: AnyObject]] {
                let decode = JSONDecoder()
                decode.dateDecodingStrategy = .millisecondsSince1970
                do {
                    let data = try JSONSerialization.data(withJSONObject: result, options: [])
                    let array = try decode.decode([Self].self, from: data)
                    completion(array)
                } catch let error {
                    print(error.localizedDescription as Any)
                    completion(nil)
                }
            }
        }
    }
    
    static private func getJSONData(method: String, params: Parameters?,  completion: @escaping (Any?) -> Void) {
        let header = ["Content-Type": "application/json"]
        ZabbixServer.id += 1
//        print(params as Any)
        getParams(method: method, params: params) { (parameters) in
            AF.request(ZabbixServer.url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: header)
                .validate()
                .responseJSON(completionHandler: { (response) in
//                    print(response.value as Any)
                    switch response.result {
                    case .failure(let error):
                        print(error.localizedDescription as Any)
                        completion(nil)
                    case .success(let value):
                        guard let result = value as? [String: Any] else {return}
                        completion(result["result"] as Any)
                        if let error =  result["error"] {
                             print( "Error:",error as Any)
                        }
                    }
                })
        }
    }
    
    
    static private func login(completion: @escaping (String?) -> Void) {
        let params = ["user": ZabbixServer.user, "password": ZabbixServer.password] as Dictionary<String, Any?>
        getJSONData(method: "user.login", params: params as Parameters) { results in
            if let token = results as? String {
                ZabbixServer.token = token
                completion(token)
            } else {
                completion(nil)
            }
        }
    }
    
    static func getParams(method: String, params: Parameters?, completion: @escaping (Parameters?) -> Void) {
        if ZabbixServer.token == nil, method != "user.login" {
            login { (token) in
                ZabbixServer.token = token
                let params = ["jsonrpc": "2.0", "method": method, "params": params, "id": ZabbixServer.id, "auth": token] as Dictionary<String, Any?>
                completion(params as Parameters)
            }
        } else {
            let params = ["jsonrpc": "2.0", "method": method, "params": params, "id": ZabbixServer.id, "auth": ZabbixServer.token] as Dictionary<String, Any?>
            completion(params as Parameters)
        }
    }
}

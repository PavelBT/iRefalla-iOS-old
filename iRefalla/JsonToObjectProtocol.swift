//
//  JsonToObjectProtocol.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 7/30/19.
//  Copyright © 2019 Pavel Balderrama. All rights reserved.
//

import Foundation

protocol JsonToObjectProtocol: Decodable {
    
}

extension JsonToObjectProtocol {
    
    /// Decodes a JSON Data object into an array of Self
    static func decodeArray(from data: Data?) -> Result<[Self], Error> {
        guard let data = data else {
            return .failure(NSError(domain: "JsonToObjectProtocol", code: -1, userInfo: [NSLocalizedDescriptionKey: "Data is nil"]))
        }
        
        do {
            let decoder = JSONDecoder()
            let array = try decoder.decode([Self].self, from: data)
            return .success(array)
        } catch {
            return .failure(error)
        }
    }
    
    /// Decodes a JSON Data object into a single instance of Self
    static func decodeObject(from data: Data?) -> Result<Self, Error> {
        guard let data = data else {
            return .failure(NSError(domain: "JsonToObjectProtocol", code: -1, userInfo: [NSLocalizedDescriptionKey: "Data is nil"]))
        }
        
        do {
            let decoder = JSONDecoder()
            let object = try decoder.decode(Self.self, from: data)
            return .success(object)
        } catch {
            return .failure(error)
        }
    }
    
    // Deprecated support for older calls, but improved
    static func jsonDecode(json: Data?) -> [Self]? {
        switch decodeArray(from: json) {
        case .success(let array):
            return array
        case .failure(let error):
            print("Decoding error: \(error.localizedDescription)")
            return nil
        }
    }
}

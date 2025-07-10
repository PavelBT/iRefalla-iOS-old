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
    
    static func jsonDecode(json: Data?) -> [Self]? {
        var array: [Self]?
        if let data = json {
            let decode = JSONDecoder()
            do {
                array = try decode.decode([Self].self, from: data)
            } catch let error {
                print(error.localizedDescription)
            }
        }
        return array
    }
}

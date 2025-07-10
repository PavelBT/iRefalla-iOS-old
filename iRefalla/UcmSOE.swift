//
//  UcmEvent.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 27/02/18.
//  Copyright © 2018 Pavel Balderrama. All rights reserved.
//

import Foundation
import Parse

enum tipoEvento: String, EnumCollection {
    case CT
    case CPR
    case CB
    case PR
    case AL
}

class UcmSOE: PFObject {

    @NSManaged var time_stamp: Date?
    @NSManaged var msec: NSNumber?
    @NSManaged var msgclass: NSNumber?
    @NSManaged var path1: String?
    @NSManaged var path3: String?
    @NSManaged var path4: String?
    @NSManaged var message_text: String?
    @NSManaged var `operator`: String?
    @NSManaged var value: NSNumber?
    
}

extension UcmSOE {
    
    var timeStamp: String?  {
        if var date = time_stamp {
            let ms = Double(truncating: msec ?? 0)/1000
            date.addTimeInterval(ms)
            return date.toStringTimeStampFormatter
        }
        return nil
    }
    
    var text: String {
        let components =  message_text?.components(separatedBy: CharacterSet.whitespacesAndNewlines)
        let text = components?[6..<components!.count-3].filter { !$0.isEmpty }.joined(separator: " ")
        return  text ?? "N/A"
    }
    
    var tipo: tipoEvento {
        let op = `operator`?.trimmingCharacters(in: .whitespacesAndNewlines)
        let operador = op == nil || op!.isEmpty ? false : true
        let valor = value == nil ? false : true
        let clase = Int(truncating: msgclass ?? 99)
        
        switch (operador,valor, clase) {
        case (true,true,10):
            return .CT
        case (true,true,11):
            return .CPR
        case (false,true,10):
            return .CB
        case (false,true,11):
            return .PR
        default:
            return .AL
        }
    }
}

extension UcmSOE: PFSubclassing {
    
    static func parseClassName() -> String {
        return "UcmOnline"
    }
    
}

extension UcmSOE: ParseManager {
    
    static var storePolicy: storePolicy {
        return .onlyNetwork
    }
    
    static var sortDefault: [NSSortDescriptor]? {
        return [NSSortDescriptor(key: "time_stamp", ascending: false),NSSortDescriptor(key: "msec", ascending: false)]
    }
}

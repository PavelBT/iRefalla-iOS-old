//
//  XMLParseHandler.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 11/09/18.
//  Copyright © 2018 Pavel Balderrama. All rights reserved.
//

import Foundation

class XMLParseHandler: NSObject {
    private var strXMLData = ""
    private var currentElement = ""
    private var passData = false
    private var passName = false
    private var layer = false
    var layers:[String] = []
    
    func parseLayer(data: Data, completion: ([String]?) -> Void) {
        let parser = XMLParser(data: data)
        parser.delegate = self
        let success = parser.parse()
        if success {
            completion(self.layers)
        } else {
            print("parse failure!")
            completion(nil)
        }
    }
}

extension XMLParseHandler: XMLParserDelegate {
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        currentElement=elementName;
        if(elementName.lowercased()=="layer" || layer ) {
            layer=true
            if(elementName.lowercased()=="name") {
                passName=true;
                layer=false
            }
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        currentElement="";
        if(elementName.lowercased()=="layer") {
            layer=false
        }
        passName=false;
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if(passName){
            //            print(string)
            layers.append(string)
        }
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("failure error: ", parseError)
    }
}

//
//  ZabbixMapViewController.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 05/12/18.
//  Copyright © 2018 Pavel Balderrama. All rights reserved.
//

import Foundation
import WebKit

class ZabbixMapViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    
    var map: ZabbixMap?
//    var elements: [ZabbixMap.Element]?
//    var links: [ZabbixMap.Link]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.navigationDelegate = self
        
        if let mapId = map?.sysmapid {
            let urlStr = "\(ZabbixServer.baseUrl)/map.php?noedit=1&sysmapid=\(mapId)&;width=&height="
            let url = URL(string: ZabbixServer.url)
            let url2 = URL(string: urlStr)
            var req = URLRequest(url: url!)
            req.httpShouldHandleCookies = true
            req.httpMethod = "POST"
            req.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let params = ["jsonrpc": "2.0", "method": "user.login", "params": ["user": ZabbixServer.user, "password": ZabbixServer.password], "id": ZabbixServer.id] as [String : Any]
            let data = try? JSONSerialization.data(withJSONObject: params as Any, options: JSONSerialization.WritingOptions.prettyPrinted)
            print(String(data: data!, encoding: String.Encoding.utf8))
            req.httpBody = data
            print(req.allHTTPHeaderFields)
            self.webView.load(req)

        }
        
//        loadData()
    }
//
//    private func loadData() {
////        ["selectIconMap": ["iconmapid", "default_iconid", "name"],"selectSelements": ["selementid", "elements", "elementtype", "label", "x", "y", "iconid_off", "iconid_on", "width"], "selectLinks": ["linkid", "selementid1", "selementid2", "drawtype"]
//        let filter = ["sysmapids": map?.sysmapid as Any] as [String : Any]
//        ZabbixMap.getData(filter: filter) { (maps) in
////            self.elements = maps?.first?.selements
////            self.links = maps?.first?.links
//            GlobalMainQueue.async {
////                print(self.elements)
//            }
//        }
//    }
}

extension ZabbixMapViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {

        
        if let mapId = map?.sysmapid {
            let urlStr = "\(ZabbixServer.baseUrl)/map.php?noedit=1&sysmapid=\(mapId)&;width=&height="
            let url = URL(string: urlStr)
            var req = URLRequest(url: url!)
            req.httpShouldHandleCookies = true
            req.httpMethod = "POST"
            req.addValue("Authorization", forHTTPHeaderField: ZabbixServer.token!)
            self.webView.load(req)

        }
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        print(challenge)
    }
}

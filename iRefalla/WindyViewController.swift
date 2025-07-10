//
//  WindyViewController.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 23/09/18.
//  Copyright © 2018 Pavel Balderrama. All rights reserved.
//

import UIKit
import WebKit

class WindyViewController: UIViewController {
    
    var webView: WKWebView!

    override func loadView() {
        super.loadView()
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        self.view = webView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
//        let myURL = Bundle.main.url(forResource: "windy", withExtension: "html")
        let myURL = URL(string: "https://www.windy.com/?19.5,-99.2,10")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

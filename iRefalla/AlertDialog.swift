//
//  AlertDialog.swift
//  iDetecta
//
//  Created by Pavel Balderrama on 23/10/17.
//  Copyright © 2017 Pavel Balderrama. All rights reserved.
//

import Foundation
import UIKit

class AlertDialog {
        
    class func ShowAlert(viewController: UIViewController, title: String, message: String?, actions userActions: [UIAlertAction]? = nil, fields: [String]? = nil, dic: [String: String]? = nil,completion: (([String]?) -> Void)?) {
        var actions = userActions ?? [UIAlertAction]()
        var results = [String]()
        let style = fields == nil && dic == nil ? UIAlertController.Style.actionSheet : UIAlertController.Style.alert
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        let okAction = UIAlertAction(title: "Aceptar", style: .default) { (alert) in
            if let fields = alertController.textFields {
                for field in fields {
                    let texto = field.text ?? ""
                    results.append(texto)
                }
                completion?(results)
            } else {
                completion?(nil)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel) { (_) in
            completion?(nil)
        }
        
        // AGREGAR CAMPOS
        if let fields = fields {
            for field in fields {
                alertController.addTextField { (textField) in
                    textField.placeholder = field
                }
            }
        }
        
        // AGREGAR CAMPOS CON DEFAULT VALUE
        if let fields = dic {
            for (key, value) in fields {
                alertController.addTextField { (textField) in
                    textField.placeholder = key
                    textField.text = value
                }
            }
        }
        // AGREGAR LAS ACCIONES
        
        if fields != nil || dic != nil {
            actions.append(okAction)
        }
        actions.append(cancelAction)
        
        for action in actions {
            alertController.addAction(action)
        }
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    class func Show(viewController: UIViewController, title: String, message: String?, completion: @escaping ((Bool) -> Void) ) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Aceptar", style: .destructive) { (alert) in
           completion(true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel) { (_) in
            completion(false)
        }
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
       
        viewController.present(alertController, animated: true, completion: nil)
    }
}

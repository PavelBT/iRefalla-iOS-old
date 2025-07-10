//
//  ViewController.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 19/04/17.
//  Copyright © 2017 Pavel Balderrama. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {

    
    @IBOutlet weak var usuarioTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    var needLogging:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextFields()
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKB))
        self.view.addGestureRecognizer(tap)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if currentUser != nil, !needLogging {
            self.updateUserData()
            self.doSegue()
        }
    }
    
    private func configureTextFields() {
        usuarioTextField.returnKeyType = .done
        passwordTextField.returnKeyType = .done

        usuarioTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    @objc private func dismissKB() {
        self.dismissKeyboard()
    }
    
    @IBAction func loginButton(_ sender: Any) {
        if let usuario = usuarioTextField.text, let pass = passwordTextField.text {
            PFUser.logInWithUsername(inBackground: usuario, password: pass) { (user, error) in
                if error == nil {
                    print("login Sucess")
                    currentUser = user
                    self.doSegue()
                } else {
                    AlertDialog.ShowAlert(viewController: self, title: "Error", message: error?.localizedDescription, completion: nil)
                }
            }
        }
    }
    
    private func updateUserData() {
        currentUser?.fetchInBackground(block: { (user, error) in
            if error == nil, let user = user as? PFUser {
                currentUser = user
            }
        })
    }
    private func doSegue() {
        self.performSegue(withIdentifier: "LoginToRegistros", sender: nil)
    }
    
    @IBAction func returnLogin(segue: UIStoryboardSegue) {
        print("return to login")
    }
}

extension LoginViewController {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        return true
    }
    
}

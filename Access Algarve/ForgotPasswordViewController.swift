//
//  ForgotPasswordViewController.swift
//  Access Algarve Light
//
//  Created by Daniel Santos on 22/03/2018.
//  Copyright © 2018 Daniel Santos. All rights reserved.
//

import UIKit
import SVProgressHUD

class ForgotPasswordViewController: UIViewController, UITextFieldDelegate {

    var user: User!
    var previousVC = "resetpassword"
    @IBOutlet var email: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func closeButtonClicked(_ sender: UIButton) {
        if previousVC == "resetpassword" {
            self.performSegue(withIdentifier: "unwindToResetPassword", sender: self)
        } else if previousVC == "login" {
            self.performSegue(withIdentifier: "unwindToLogin", sender: self)
        }
    }
    
    @IBAction func sendButtonClicked(_ sender: Any) {
        DispatchQueue.main.async {SVProgressHUD.show(withStatus: "Loading")}
        let params = ["email": self.email.text!]
        getAPIResults(endpoint: "users/forgotpassword", parameters: params) { data in
            DispatchQueue.main.async {
                do {
                    //: Save user in app defaults
                    self.user = try User.decode(data: data)
                    let defaults = UserDefaults.standard
                    let encodedUser = try self.user.encode()
                    defaults.set(encodedUser, forKey: "SavedUser")
                    SVProgressHUD.dismiss()
                    if self.previousVC == "resetpassword" {
                        self.performSegue(withIdentifier: "unwindToResetPassword", sender: self)
                    } else if self.previousVC == "login" {
                        self.performSegue(withIdentifier: "unwindToLogin", sender: self)
                    }
                } catch {
                    //: Alert error changing password
                    SVProgressHUD.dismiss()
                    let alert = UIAlertController(title: "Error", message: "Error sending password to your email please try again.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
}

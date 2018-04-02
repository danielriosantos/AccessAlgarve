//
//  LoginViewController.swift
//  Access Algarve Light
//
//  Created by Daniel Santos on 17/03/2018.
//  Copyright © 2018 Daniel Santos. All rights reserved.
//

import UIKit
import SVProgressHUD

class LoginViewController: UIViewController {

    @IBOutlet var email: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var loginFacebookButton: UIButton!
    
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "correctCredentialsSegue" {
            
        }
    }
    
    @IBAction func checkLoginCredentials(_ sender: UIButton) {
        DispatchQueue.main.async {SVProgressHUD.show(withStatus: "Loading")}
        let params = ["email": email.text!, "password": password.text!]
        postAPIResults(endpoint: "users/authenticate", parameters: params) { data in
            do {
                //: Try to decode user if authentication is correct
                print(String(data: data, encoding: .utf8)!)
                self.user = try User.decode(data: data)
                self.user.status = 1
                //: Save user status on UserDefaults
                let encodedUser = try self.user.encode()
                let defaults = UserDefaults.standard
                defaults.set(encodedUser, forKey: "SavedUser")
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    let params = ["status": 1]
                    self.putAPIResults(endpoint: "users/" + String(self.user.id), parameters: params) {_ in}
                    self.performSegue(withIdentifier: "correctCredentialsSegue", sender: self)
                }
            } catch {
                //: Authentication was wrong, alert user
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    let alert = UIAlertController(title: "Error", message: "The email and password provided were not recognized", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func unwindToLoginViewController(_ segue: UIStoryboardSegue) {
        
    }

}

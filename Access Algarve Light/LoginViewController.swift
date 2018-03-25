//
//  LoginViewController.swift
//  Access Algarve Light
//
//  Created by Daniel Santos on 17/03/2018.
//  Copyright © 2018 Daniel Santos. All rights reserved.
//

import UIKit

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
        let parameters = ["email": email.text!, "password": password.text!]
        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(parameters)
            postAPIResults(endpoint: "users/authenticate", parameters: jsonData) { data in
                do {
                    //: Try to decode user if authentication is correct
                    self.user = try User.decode(data: data)
                    self.user.status = 1
                    //: Save user status on UserDefaults
                    let encodedUser = try self.user.encode()
                    let defaults = UserDefaults.standard
                    defaults.set(encodedUser, forKey: "SavedUser")
                    DispatchQueue.main.async {
                        let parameters = ["status": 1]
                        let encoder = JSONEncoder()
                        do {
                            let jsonData = try encoder.encode(parameters)
                            self.putAPIResults(endpoint: "users/" + String(self.user.id), parameters: jsonData) {_ in}
                        } catch {
                            print(error)
                        }
                        self.performSegue(withIdentifier: "correctCredentialsSegue", sender: self)
                    }
                } catch {
                    //: Authentication was wrong, alert user
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Error", message: "The email and password provided were not recognized", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        } catch {
            print("Error encoding json data")
        }
    }
    
    @IBAction func unwindToLoginViewController(_ segue: UIStoryboardSegue) {
        
    }

}

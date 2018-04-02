//
//  CreateAccountViewController.swift
//  Access Algarve Light
//
//  Created by Daniel Santos on 19/03/2018.
//  Copyright © 2018 Daniel Santos. All rights reserved.
//

import UIKit
import SVProgressHUD

class CreateAccountViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var email: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var confirmpassword: UITextField!
    @IBOutlet var name: UITextField!
    @IBOutlet var country: UITextField!
    @IBOutlet var createButton: UIButton!
    @IBOutlet var loginFacebook: UIButton!
    
    var user: User!
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Try to find next responder
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
        }
        // Do not add a line break
        return false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "createAccountSegue" {
//            guard let setUserPinViewController = segue.destination as? SetUserPinViewController else {return}
//            setUserPinViewController.user = user
//        }
//    }
    
    @IBAction func createAccount(_ sender: Any) {
        //self.performSegue(withIdentifier: "createAccountSegue", sender: self)
        if password.text!.count > 7 {
            if password.text == confirmpassword.text {
                DispatchQueue.main.async {SVProgressHUD.show(withStatus: "Loading")}
                let params = [
                    "name": name.text!,
                    "email": email.text!,
                    "password": password.text!,
                    "country": country.text!
                ]
                postAPIResults(endpoint: "users", parameters: params) { data in
                    DispatchQueue.main.async {
                        do {
                            //: Save user in app defaults
                            self.user = try User.decode(data: data)
                            //self.user.status = 0
                            //self.user.country = self.country.text
                            let defaults = UserDefaults.standard
                            let encodedUser = try self.user.encode()
                            defaults.set(encodedUser, forKey: "SavedUser")
                            SVProgressHUD.dismiss()
                            self.performSegue(withIdentifier: "createAccountSegue", sender: self)
                        } catch {
                            //: Alert wrong user pass message
                            SVProgressHUD.dismiss()
                            let alert = UIAlertController(title: "Error", message: "Error Creating Your Account. The account you're trying to create might already exist or please try again.", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            } else {
                let alert = UIAlertController(title: "Error", message: "The passwords do not match", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            let alert = UIAlertController(title: "Error", message: "The passwords needs to contain at least 8 characters", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}

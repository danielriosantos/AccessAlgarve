//
//  ResetPasswordViewController.swift
//  Access Algarve
//
//  Created by Daniel Santos on 04/04/2018.
//  Copyright © 2018 Daniel Santos. All rights reserved.
//

import UIKit
import SVProgressHUD

class ResetPasswordViewController: UIViewController, UITextFieldDelegate {
 
    @IBOutlet weak var oldPassword: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!

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
    
    @IBAction func updateButtonClicked(_ sender: UIButton) {
        let defaults = UserDefaults.standard
        if let savedUser = defaults.object(forKey: "SavedUser") as? Data {
            do {
                self.user = try User.decode(data: savedUser)
                if newPassword.text!.count > 7 {
                    if newPassword.text == confirmPassword.text {
                        DispatchQueue.main.async {SVProgressHUD.show(withStatus: "Loading")}
                        let params = [
                            "oldpassword": oldPassword.text!,
                            "password": newPassword.text!
                        ] as [String : Any]
                        putAPIResults(endpoint: "users/" + String(user.id), parameters: params) { data in
                            DispatchQueue.main.async {
                                do {
                                    //: Save user in app defaults
                                    self.user = try User.decode(data: data)
                                    let defaults = UserDefaults.standard
                                    let encodedUser = try self.user.encode()
                                    defaults.set(encodedUser, forKey: "SavedUser")
                                    SVProgressHUD.dismiss()
                                    self.performSegue(withIdentifier: "goToLoginSegue", sender: self)
                                } catch {
                                    //: Alert error changing password
                                    SVProgressHUD.dismiss()
                                    let alert = UIAlertController(title: "Error", message: "Error changing your password please try again.", preferredStyle: UIAlertControllerStyle.alert)
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
            } catch {
                print("Error decoding user data from defaults")
            }
        }
    }
    
    @IBAction func unwindToResetPasswordViewController(_ segue: UIStoryboardSegue) {
        
    }

}

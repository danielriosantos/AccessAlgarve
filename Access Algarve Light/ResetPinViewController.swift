//
//  ResetPinViewController.swift
//  Access Algarve Light
//
//  Created by Daniel Santos on 22/03/2018.
//  Copyright © 2018 Daniel Santos. All rights reserved.
//

import UIKit

class ResetPinViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var oldPIN1: UITextField!
    @IBOutlet var oldPIN2: UITextField!
    @IBOutlet var oldPIN3: UITextField!
    @IBOutlet var oldPIN4: UITextField!
    @IBOutlet var newPIN1: UITextField!
    @IBOutlet var newPIN2: UITextField!
    @IBOutlet var newPIN3: UITextField!
    @IBOutlet var newPIN4: UITextField!
    
    var user: User!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return textField.shouldChangeCustomOtp(textField: textField, string: string)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        oldPIN1.delegate = self
        oldPIN2.delegate = self
        oldPIN3.delegate = self
        oldPIN4.delegate = self
        newPIN1.delegate = self
        newPIN2.delegate = self
        newPIN3.delegate = self
        newPIN4.delegate = self
    }

    @IBAction func updateButtonClicked(_ sender: Any) {
        let defaults = UserDefaults.standard
        do {
            //let oldPIN = oldPIN1.text! + oldPIN2.text! + oldPIN3.text! + oldPIN4.text!
            let newPIN = newPIN1.text! + newPIN2.text! + newPIN3.text! + newPIN4.text!
            if newPIN.count == 4 /*&& oldPIN == user.pin*/ {
                user.pin = newPIN
                let encodedUser = try user.encode()
                defaults.set(encodedUser, forKey: "SavedUser")
                let parameters = ["pin": newPIN]
                let encoder = JSONEncoder()
                do {
                    let jsonData = try encoder.encode(parameters)
                    self.putAPIResults(endpoint: "users/" + String(self.user.id), parameters: jsonData) {_ in}
                } catch {
                    print(error)
                }
            }
        } catch {
            print("Problem encoding user")
        }
        self.performSegue(withIdentifier: "unwindToSettings", sender: self)
    }
    
}

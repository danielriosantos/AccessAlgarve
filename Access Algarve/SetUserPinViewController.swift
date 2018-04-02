//
//  SetUserPinViewController.swift
//  Access Algarve Light
//
//  Created by Daniel Santos on 20/03/2018.
//  Copyright © 2018 Daniel Santos. All rights reserved.
//

import UIKit

class SetUserPinViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var pin1: UITextField!
    @IBOutlet var pin2: UITextField!
    @IBOutlet var pin3: UITextField!
    @IBOutlet var pin4: UITextField!
    @IBOutlet var confirmButton: UIButton!
    
    var user: User!
    
    var max = 1
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return textField.shouldChangeCustomOtp(textField: textField, string: string)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pin1.delegate = self
        pin2.delegate = self
        pin3.delegate = self
        pin4.delegate = self
    }
    
    @IBAction func validateUserPin(_ sender: UIButton) {
        let enteredPIN = pin1.text! + pin2.text! + pin3.text! + pin4.text!
        if enteredPIN.count == 4 {
            //: Save user pin on UserDefaults
            let defaults = UserDefaults.standard
            if let savedUser = defaults.object(forKey: "SavedUser") as? Data {
                do {
                    user = try User.decode(data: savedUser)
                    user.pin = enteredPIN
                    let encodedUser = try self.user.encode()
                    defaults.set(encodedUser, forKey: "SavedUser")
                    let params = ["pin": enteredPIN]
                    self.putAPIResults(endpoint: "users/" + String(self.user.id), parameters: params) {_ in}
                    self.performSegue(withIdentifier: "validUserPinSegue", sender: self)
                } catch {
                    print("Error decoding user data from defaults")
                }
            }
        } else {
            let alert = UIAlertController(title: "Error", message: "The PIN must contain 4 numbers exactly", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

}

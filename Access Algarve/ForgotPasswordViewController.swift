//
//  ForgotPasswordViewController.swift
//  Access Algarve Light
//
//  Created by Daniel Santos on 22/03/2018.
//  Copyright © 2018 Daniel Santos. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: UIViewController {

    @IBOutlet var email: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func sendButtonClicked(_ sender: Any) {
        self.performSegue(withIdentifier: "unwindToLoginViewController", sender: self)
    }
    
}

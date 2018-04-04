//
//  LicenseViewController.swift
//  Access Algarve
//
//  Created by Daniel Santos on 04/04/2018.
//  Copyright © 2018 Daniel Santos. All rights reserved.
//

import UIKit

class LicenseViewController: UIViewController {

    var previousVC = "settings"
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func backButtonClicked(_ sender: UIButton) {
        switch previousVC {
        case "login":
            self.performSegue(withIdentifier: "unwindToLogin", sender: self)
        default:
            self.performSegue(withIdentifier: "unwindToSettings", sender: self)
        }
    }
    
}

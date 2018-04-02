//
//  ProfileSettingsViewController.swift
//  Access Algarve
//
//  Created by Daniel Santos on 02/04/2018.
//  Copyright © 2018 Daniel Santos. All rights reserved.
//

import UIKit

class ProfileSettingsViewController: UIViewController {

    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userBirthday: UITextField!
    @IBOutlet weak var userMobile: UITextField!
    @IBOutlet weak var userNationality: UITextField!
    @IBOutlet weak var userCountry: UITextField!
    @IBOutlet weak var userNotifications: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func backButtonClicked(_ sender: UIButton) {
        //: Save settings and go back
        self.performSegue(withIdentifier: "unwindToSettingsSegue", sender: self)
    }
    
}

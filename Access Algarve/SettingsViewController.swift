//
//  SettingsViewController.swift
//  Access Algarve Light
//
//  Created by Daniel Santos on 18/03/2018.
//  Copyright © 2018 Daniel Santos. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class SettingsViewController: UIViewController {

    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "logOutSegue"?:
            let defaults = UserDefaults.standard
            if let savedUser = defaults.object(forKey: "SavedUser") as? Data {
                do {
                    user = try User.decode(data: savedUser)
                    user.status = 0
                    //let encodedUser = try user.encode()
                    //defaults.set(encodedUser, forKey: "SavedUser")
                    defaults.set(nil, forKey: "SavedUser")
                    let params = ["status": 0]
                    self.putAPIResults(endpoint: "users/" + String(user.id), parameters: params) {_ in}
                    DispatchQueue.main.async {
                        let loginManager = FBSDKLoginManager()
                        loginManager.logOut()
                    }
                } catch {
                    print("Problem encoding user")
                }
            }
        case "licenseSegue"?:
            guard let licenseViewController = segue.destination as? LicenseViewController else {return}
            licenseViewController.previousVC = "settings"
/*
        case "resetPinSegue"?:
            let defaults = UserDefaults.standard
            if let savedUser = defaults.object(forKey: "SavedUser") as? Data {
                do {
                    user = try User.decode(data: savedUser)
                    guard let resetPinViewController = segue.destination as? ResetPinViewController else {return}
                    resetPinViewController.user = user
                } catch {
                    print("Problem decoding user")
                }
            }
 */
        default:
            break
            
        }
    }
    
    @IBAction func unwindToSettingsViewController(_ segue: UIStoryboardSegue) {
        
    }

}

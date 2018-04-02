//
//  ProfileSettingsViewController.swift
//  Access Algarve
//
//  Created by Daniel Santos on 02/04/2018.
//  Copyright © 2018 Daniel Santos. All rights reserved.
//

import UIKit

class ProfileSettingsViewController: UIViewController {

    var user: User!
    
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userBirthday: UITextField!
    @IBOutlet weak var userMobile: UITextField!
    @IBOutlet weak var userNationality: UITextField!
    @IBOutlet weak var userCountry: UITextField!
    @IBOutlet weak var userNotifications: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        if let savedUser = defaults.object(forKey: "SavedUser") as? Data {
            do {
                self.user = try User.decode(data: savedUser)
                userName.text = user.name
                userEmail.text = user.email
                userBirthday.text = user.birthday
                userMobile.text = user.mobile
                userNationality.text = user.nationality
                userCountry.text = user.country
                if user.notifications == 1 {userNotifications.isOn = true} else {userNotifications.isOn = false}
            } catch {
                print("Error decoding user data from defaults")
            }
        }

    }

    @IBAction func backButtonClicked(_ sender: UIButton) {
        //: Save settings and go back
        do {
            let encodedUser = try self.user.encode()
            let defaults = UserDefaults.standard
            defaults.set(encodedUser, forKey: "SavedUser")
            DispatchQueue.main.async {
                var params = [
                    "name": self.user.name,
                    "email": self.user.email
                ] as [String : Any]
                if self.user.birthday != nil {params["birthday"] = self.user.birthday!}
                if self.user.mobile != nil {params["mobile"] = self.user.mobile!}
                if self.user.nationality != nil {params["nationality"] = self.user.nationality!}
                if self.user.country != nil {params["country"] = self.user.country!}
                if self.user.notifications != nil {params["notifications"] = self.user.notifications!}
                self.putAPIResults(endpoint: "users/" + String(self.user.id), parameters: params) {userData in
                    print(String(data: userData, encoding: .utf8)!)
                }
                //self.performSegue(withIdentifier: "unwindToSettingsSegue", sender: self)
            }
        } catch {
            print("Error encoding user data to defaults")
        }
        
    }
    
}

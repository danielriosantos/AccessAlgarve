//
//  UserProfileViewController.swift
//  Access Algarve Light
//
//  Created by Daniel Santos on 22/03/2018.
//  Copyright © 2018 Daniel Santos. All rights reserved.
//

import UIKit

class UserProfileViewController: UIViewController {

    var user: User!
    
    @IBOutlet var userName: UILabel!
    @IBOutlet var userEmail: UILabel!
    @IBOutlet var amountSaved: UILabel!
    @IBOutlet var offersUsed: UILabel!
    @IBOutlet var friendsUsingApp: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults = UserDefaults.standard
        if let savedUser = defaults.object(forKey: "SavedUser") as? Data {
            do {
                self.user = try User.decode(data: savedUser)
                userName.text = user.name
                userEmail.text = user.email
            } catch {
                print("Error decoding user data from defaults")
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    @IBAction func unwindToUserProfileViewController(_ segue: UIStoryboardSegue) {
        
    }

}

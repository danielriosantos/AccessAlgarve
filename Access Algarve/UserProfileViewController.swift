//
//  UserProfileViewController.swift
//  Access Algarve Light
//
//  Created by Daniel Santos on 22/03/2018.
//  Copyright © 2018 Daniel Santos. All rights reserved.
//

import UIKit
import CoreLocation
import SVProgressHUD

class UserProfileViewController: UIViewController, CLLocationManagerDelegate {

    var user: User!
    let locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    @IBOutlet var userName: UILabel!
    @IBOutlet var userEmail: UILabel!
    @IBOutlet var amountSaved: UILabel!
    @IBOutlet var offersUsed: UILabel!
    @IBOutlet var friendsUsingApp: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.delegate = self
        
        //: Handle location
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.distanceFilter = 100
        
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
        
        //: Get user from database and update defaults
        DispatchQueue.main.async {SVProgressHUD.show(withStatus: "Loading")}
        loadUser(user_id: user.id) {dbUser in
            DispatchQueue.main.async {
                self.user = dbUser
                var savedAmount: Double = 0
                for redemption in self.user.redemptions {
                    savedAmount += Double(redemption.offer.max_savings)! / Double(redemption.offer.quantity)
                }
                self.amountSaved.text = String(Int(savedAmount.rounded(.up)))
                self.offersUsed.text = String(self.user.redemptions.count)
                SVProgressHUD.dismiss()
            }
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            currentLocation = location
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueidentifier = segue.identifier else {return}
        if segueidentifier == "showFavourites" {
            guard let favouritesViewController = segue.destination as? FavouritesViewController else {return}
            favouritesViewController.currentLocation = currentLocation
        }
    }
    
    @IBAction func unwindToUserProfileViewController(_ segue: UIStoryboardSegue) {
        
    }

}

//
//  UserProfileViewController.swift
//  Access Algarve Light
//
//  Created by Daniel Santos on 22/03/2018.
//  Copyright © 2018 Daniel Santos. All rights reserved.
//

import UIKit
import CoreLocation

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

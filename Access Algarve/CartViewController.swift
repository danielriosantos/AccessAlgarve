//
//  CartViewController.swift
//  Access Algarve Light
//
//  Created by Daniel Santos on 22/03/2018.
//  Copyright © 2018 Daniel Santos. All rights reserved.
//

import UIKit
import CoreLocation

class CartViewController: UIViewController, CLLocationManagerDelegate {

    let locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.delegate = self
        
        //: Handle location
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.distanceFilter = 100
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
    
    @IBAction func unwindToCartViewController(_ segue: UIStoryboardSegue) {
        
    }

}

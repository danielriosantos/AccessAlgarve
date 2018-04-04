//
//  RedeemSuccessViewController.swift
//  Access Algarve Light
//
//  Created by Daniel Santos on 15/03/2018.
//  Copyright © 2018 Daniel Santos. All rights reserved.
//

import UIKit
import CoreLocation

class RedeemSuccessViewController: UIViewController, CLLocationManagerDelegate {

    let locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    @IBOutlet weak var voucherBackground: UIView!
    @IBOutlet weak var smileImage: UIImageView!
    @IBOutlet weak var redeemCongrats: UILabel!
    @IBOutlet weak var redeemSuccessMessage: UILabel!
    @IBOutlet weak var enjoyLabel: UILabel!
    
    var outlet: Outlet!
    var offer: Offer!
    
    //: Define Colors
    let pink = UIColor(red: 221.0/255.0, green: 78.0/255.0, blue: 149.0/255.0, alpha: 1.0)
    let orange = UIColor(red: 235.0/255.0, green: 128.0/255.0, blue: 0.0/255.0, alpha: 1.0)
    let blue = UIColor(red: 64.0/255.0, green: 191.0/255.0, blue: 239.0/255.0, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.delegate = self

        //: Handle location
        locationManager.startUpdatingLocation()
        locationManager.distanceFilter = 100
        
        //: Set Colors
        var currentColor: UIColor
        var currentColorName: String
        switch offer.offer_category_id {
        case 1:
            currentColor = pink
            currentColorName = "pink"
        case 3:
            currentColor = orange
            currentColorName = "orange"
        default:
            currentColor = blue
            currentColorName = "blue"
        }
        voucherBackground.backgroundColor = currentColor
        smileImage.image = UIImage(named: currentColorName + "-smile-face")
        redeemCongrats.textColor = currentColor
        redeemSuccessMessage.textColor = currentColor
        enjoyLabel.textColor = currentColor

    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            currentLocation = location
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       if segue.identifier == "showFavourites" {
            guard let favouritesViewController = segue.destination as? FavouritesViewController else {return}
            favouritesViewController.currentLocation = currentLocation
        }
    }

}

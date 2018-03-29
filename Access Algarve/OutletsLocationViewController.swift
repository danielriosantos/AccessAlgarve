//
//  OutletsLocationViewController.swift
//  Access Algarve
//
//  Created by Daniel Santos on 29/03/2018.
//  Copyright © 2018 Daniel Santos. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class OutletsLocationViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var map: MKMapView!
    
    var outlets = [Outlet]()
    var outletresultscontainer: OutletResults!
    var currentColor: UIColor!
    let locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    //: Define Colors
    let pink = UIColor(red: 221.0/255.0, green: 78.0/255.0, blue: 149.0/255.0, alpha: 1.0)
    let orange = UIColor(red: 235.0/255.0, green: 128.0/255.0, blue: 0.0/255.0, alpha: 1.0)
    let blue = UIColor(red: 64.0/255.0, green: 191.0/255.0, blue: 239.0/255.0, alpha: 1.0)
    let white = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0)
    let invisible = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        self.locationManager.delegate = self
        
        //: Handle location
        locationManager.startUpdatingLocation()
        locationManager.distanceFilter = 100
        
        //: Add title to navigation bar
        self.navigationItem.title = "Map View"
        
        //: Add pinpoint
        for outlet in outlets {
            let annotation = MKPointAnnotation()
            let coordstring = outlet.gps.replacingOccurrences(of: " ", with: "")
            if  coordstring != "" {
                let coordsArr = coordstring.components(separatedBy: ",")
                let outletLocation = CLLocationCoordinate2DMake(CLLocationDegrees(coordsArr[0])!, CLLocationDegrees(coordsArr[1])!)
                annotation.coordinate = outletLocation
                map.addAnnotation(annotation)
            }
        }
        
        //: Show user location and center
        map.showsUserLocation = true
        let userLocation = CLLocationCoordinate2DMake(self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude)
        let viewRegion = MKCoordinateRegionMakeWithDistance(userLocation, 20000, 20000)
        map.setRegion(viewRegion, animated: true)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            currentLocation = location
        }
    }

}

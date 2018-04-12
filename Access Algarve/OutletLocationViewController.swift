//
//  OutletLocationViewController.swift
//  Access Algarve Light
//
//  Created by Daniel Santos on 16/03/2018.
//  Copyright © 2018 Daniel Santos. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class OutletLocationViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var map: MKMapView!
    
    var outlet: Outlet!
    let locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocation!
    var pin: AnnotationPin!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.delegate = self
        
        //: Handle location
        locationManager.startUpdatingLocation()
        locationManager.distanceFilter = 100
        
        //: Add title to navigation bar
        self.navigationItem.title = outlet.name + " Location"
        
        //: Add pinpoint
        let coordstring = outlet.gps.replacingOccurrences(of: " ", with: "")
        if  coordstring != "" {
            let coordsArr = coordstring.components(separatedBy: ",")
            let outletLocation = CLLocationCoordinate2DMake(CLLocationDegrees(coordsArr[0])!, CLLocationDegrees(coordsArr[1])!)
            pin = AnnotationPin(Title: outlet.name, Subtitle: outlet.city, Coordinate: outletLocation)
            map.addAnnotation(pin)
        }
        
        //: Show user location and center
        if self.currentLocation != nil {
            map.showsUserLocation = true
            let userLocation = CLLocationCoordinate2DMake(self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude)
            var outletLocation: CLLocation!
            var distance: CLLocationDistance = 0
            if  coordstring != "" {
                let coordsArr = coordstring.components(separatedBy: ",")
                outletLocation = CLLocation(latitude: CLLocationDegrees(coordsArr[0])!, longitude: CLLocationDegrees(coordsArr[1])!)
            }
            if outletLocation != nil {
                distance = outletLocation.distance(from: self.currentLocation) * 2.2
                let viewRegion = MKCoordinateRegionMakeWithDistance(userLocation, distance, distance)
                map.setRegion(viewRegion, animated: true)
            }
        }
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            currentLocation = location
        }
    }

}

//
//  OutletLocationViewController.swift
//  Access Algarve Light
//
//  Created by Daniel Santos on 16/03/2018.
//  Copyright © 2018 Daniel Santos. All rights reserved.
//

import UIKit
import MapKit

class OutletLocationViewController: UIViewController {

    @IBOutlet weak var map: MKMapView!
    
    var outlet: Outlet!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = outlet.name + " Location"
        let annotation = MKPointAnnotation()
        let coordstring = outlet.gps.replacingOccurrences(of: " ", with: "")
        if  coordstring != "" {
            let coordsArr = coordstring.components(separatedBy: ",")
            annotation.coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(coordsArr[0])!, CLLocationDegrees(coordsArr[1])!)
            map.addAnnotation(annotation)
        }
    }

}

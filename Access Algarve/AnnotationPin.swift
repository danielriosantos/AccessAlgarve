//
//  AnnotationPin.swift
//  Access Algarve
//
//  Created by Daniel Santos on 29/03/2018.
//  Copyright © 2018 Daniel Santos. All rights reserved.
//

import MapKit

class AnnotationPin: NSObject, MKAnnotation {
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    
    init(Title: String, Subtitle: String, Coordinate: CLLocationCoordinate2D) {
        self.title = Title
        self.subtitle = Subtitle
        self.coordinate = Coordinate
    }
}

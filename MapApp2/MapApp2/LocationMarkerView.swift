//
//  LocationView.swift
//  MapApp2
//
//  Created by Melissa Zhang on 12/22/17.
//  Copyright © 2017 Melissa Zhang. All rights reserved.
//

import Foundation
import MapKit

class LocationMarkerView: MKMarkerAnnotationView {
    override var annotation: MKAnnotation? {
        willSet {
            guard let location = newValue as? Location else { return }
            canShowCallout = true
            calloutOffset = CGPoint(x: -5, y: 5)
            rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            markerTintColor = location.pinTintColor
            if let imageName = location.imageName, location.imageName == "smallHouse" {
                glyphImage = UIImage(named: imageName)
            }
        }
    }
}

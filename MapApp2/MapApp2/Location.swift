//
//  Locations.swift
//  Park View
//
//  Created by Melissa Zhang on 12/20/17.
//  Copyright © 2017 Ray Wenderlich. All rights reserved.
//

import Foundation
import MapKit

class Location: NSObject, MKAnnotation, NSCoding {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: "title")
        aCoder.encode(NSNumber(value: coordinate.latitude), forKey: "latitude")
        aCoder.encode(NSNumber(value: coordinate.longitude), forKey: "longitude")
        aCoder.encode(category, forKey: "category")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let title = aDecoder.decodeObject(forKey: "title") as? String ?? ""
        let latitude = aDecoder.decodeObject(forKey: "latitude") as? NSNumber ?? 0
        let longitude = aDecoder.decodeObject(forKey: "longitude") as? NSNumber ?? 0
        let category = aDecoder.decodeObject(forKey: "category") as? String ?? ""
        let coordinate = CLLocationCoordinate2D(latitude: latitude.doubleValue, longitude: longitude.doubleValue)
        self.init(locationName: title, coordinate: coordinate, category: category)
    }
    
    var title: String?
    let coordinate: CLLocationCoordinate2D
    var category: String?
    
    var identifier: Int
    static var makeIdentifier = 0
        
    init(locationName: String, coordinate: CLLocationCoordinate2D) {
        self.title = locationName
        self.coordinate = coordinate
        self.identifier = Location.getIdentifier()
        
        super.init()
    }
    
    convenience init(locationName: String, coordinate: CLLocationCoordinate2D, category: String) {
        self.init(locationName: locationName, coordinate: coordinate)
        self.category = category
    }
    
    var pinTintColor: UIColor  {
        switch category ?? "" {
        case "Visited":
            return #colorLiteral(red: 0.3414919165, green: 0.7411550656, blue: 0.3761762391, alpha: 1)
        case "Destination":
            return #colorLiteral(red: 0.954612151, green: 0.8681329543, blue: 0.4377564396, alpha: 1)
        case "Home":
            return .red
        default:
            return .red
        }
    }
    
    var imageName: String? {
        if category == "Home" {
            return "smallHouse"
        }
        return ""
    }
    
    static func getIdentifier() -> Int {
        makeIdentifier += 1
        return makeIdentifier
    }
    
    public override var description: String { return "Name: \(title ?? "")" }
}

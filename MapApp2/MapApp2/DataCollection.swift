//  Data.swift
//  Park View
//
//  Created by Melissa Zhang on 12/20/17.
//  Copyright © 2017 Ray Wenderlich. All rights reserved.
//

import Foundation
import MapKit

class DataCollection {
    var locations = [Location]() {
        didSet {
            let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: locations)
            UserDefaults.standard.set(encodedData, forKey: "locations")
            UserDefaults.standard.synchronize()
        }
    }
    var visited = [Location]()
    var destinations = [Location]()
    var home: Location?
    
    func restoreData() {
        guard let decoded = UserDefaults.standard.object(forKey: "locations") as? Data else {
            return
        }
        let decodedLocations = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! [Location]
        
        locations = decodedLocations
        
        for location in decodedLocations {
            if location.category == "Visited" {
                visited.append(location)
            } else if location.category == "Destination" {
                destinations.append(location)
            } else if location.category == "Home" {
                home = location
            }
        }
    }
}


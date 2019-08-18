//
//  LocationDistance.swift
//  AmplerTests
//
//  Created by Haik Ampardjian on 8/17/19.
//  Copyright © 2019 Haik Ampardjian. All rights reserved.
//

import Foundation
import CoreLocation

final class LocationDistance {
    // Returns in meters
    func computeDistance(coordinates: [CLLocationCoordinate2D]) -> CLLocationDistance {
        guard coordinates.count > 1 else { return 0 }
        
        var distance: CLLocationDistance = 0
        for index in 0..<(coordinates.count - 1) {
            let location1 = location(coordinate: coordinates[index])
            let location2 = location(coordinate: coordinates[index + 1])
            let distanceBetweenLocations = location1.distance(from: location2)
            distance += distanceBetweenLocations
        }
        
        return distance
    }
    
    private func location(coordinate: CLLocationCoordinate2D) -> CLLocation {
        return CLLocation(latitude: coordinate.latitude,
                          longitude: coordinate.longitude)
    }
}

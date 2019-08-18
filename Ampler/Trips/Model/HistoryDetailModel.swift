//
//  HistoryDetailModel.swift
//  Ampler
//
//  Created by Haik Ampardjian on 8/18/19.
//  Copyright © 2019 Haik Ampardjian. All rights reserved.
//

import Foundation
import CoreLocation

final class HistoryDetailModel {
    let trip: Trip

    var coordinatesForPolyline: [CLLocationCoordinate2D] {
        let tripSortedCoordinates = trip.coordinates.sorted(by: { $0.index < $1.index })
        return tripSortedCoordinates.map({ CLLocationCoordinate2D.init(latitude: $0.latitude, longitude: $0.longitude) })
    }
    
    var totalDistance: CLLocationDistance {
        let distanceProcessor = LocationDistance()
        let meters = distanceProcessor.computeDistance(coordinates: coordinatesForPolyline)
        return meters
    }
    
    var centerLocation: CLLocationCoordinate2D {
        return coordinatesForPolyline[coordinatesForPolyline.count / 2]
    }

    init(with trip: Trip) {
        self.trip = trip
    }
}

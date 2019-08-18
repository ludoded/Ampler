//
//  Coordinate.swift
//  Ampler
//
//  Created by Haik Ampardjian on 8/17/19.
//  Copyright © 2019 Haik Ampardjian. All rights reserved.
//

import CoreData
import CoreLocation

final class Coordinate: NSManagedObject {
    @NSManaged fileprivate(set) var index: Int16
    @NSManaged fileprivate(set) var latitude: Double
    @NSManaged fileprivate(set) var longitude: Double
    
    @NSManaged fileprivate(set) var trip: Trip
}

extension Coordinate: Managed {
    static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: #keyPath(index), ascending: false)]
    }
}

extension Coordinate {
    @discardableResult
    static func insert(into moc: NSManagedObjectContext, from coordinates: CLLocationCoordinate2D, number: Int, trip: Trip) -> Coordinate {
        let coord: Coordinate = moc.insertObject()
        coord.latitude = coordinates.latitude
        coord.longitude = coordinates.longitude
        coord.index = Int16(number)
        coord.trip = trip
        
        return coord
    }
}

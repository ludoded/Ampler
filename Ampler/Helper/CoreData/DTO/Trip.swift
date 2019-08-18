//
//  Trip.swift
//  Ampler
//
//  Created by Haik Ampardjian on 8/17/19.
//  Copyright © 2019 Haik Ampardjian. All rights reserved.
//

import CoreData
import CoreLocation

final class Trip: NSManagedObject {
    @NSManaged fileprivate(set) var startDate: Date
    @NSManaged fileprivate(set) var endDate: Date
    
    @NSManaged fileprivate(set) var coordinates: Set<Coordinate>
}

extension Trip: Managed {
    static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: #keyPath(startDate), ascending: true)]
    }
}

extension Trip {
    @discardableResult
    static func insert(into moc: NSManagedObjectContext, from tripSession: TripSession) -> Trip {
        let trip: Trip = moc.insertObject()
        trip.startDate = tripSession.startDate!
        trip.endDate = tripSession.stopDate!
        
        var coordRelations = Set<Coordinate>()
        for (index, coordinates) in tripSession.locationService.locationDataArray.enumerated() {
            let coord = Coordinate.insert(into: moc, from: coordinates.coordinate, number: index, trip: trip)
            coordRelations.insert(coord)
        }
        
        trip.coordinates = coordRelations
        
        return trip
    }
}

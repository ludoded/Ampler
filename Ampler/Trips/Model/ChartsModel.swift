//
//  ChartsModel.swift
//  Ampler
//
//  Created by Haik Ampardjian on 8/18/19.
//  Copyright © 2019 Haik Ampardjian. All rights reserved.
//

import Foundation
import CoreLocation
import CoreData
import Charts

enum DistanceMetric: Int {
    case kilometers
    case miles
    
    func convertFromMeters(_ meters: Double) -> Double {
        switch self {
        case .kilometers:
            return meters / 1000
        case .miles:
            return meters / 1609
        }
    }
}

final class ChartsModel {
    let fetchRequest: NSFetchRequest<Trip>
    
    init() {
        fetchRequest = Trip.sortedFetchRequest
    }
    
    func fetchTrips() throws -> [Trip] {
        guard let moc = PersistentStoreManager.shared.moc else { fatalError() }
        let trips = try moc.fetch(fetchRequest)
        return trips
    }
    
    func dataForChart(forMetric metric: DistanceMetric) -> BarChartData {
        guard let trips = try? fetchTrips() else { fatalError() }
        
        var viewModels: [TripChartViewModel] = []
        let locationDistance = LocationDistance()
        
        let weekDayFormatter = DateFormatter()
        weekDayFormatter.dateFormat = "E"
        
        var prevWeekday = ""
        for trip in trips {
            let weekday = weekDayFormatter.string(from: trip.startDate)
            let coords = trip.coordinates.sorted(by: { $0.index > $1.index }).map({ CLLocationCoordinate2D.init(latitude: $0.latitude, longitude: $0.longitude) })
            let val = locationDistance.computeDistance(coordinates: coords)
            
            if prevWeekday != weekday {
                viewModels.append(TripChartViewModel.init(val: val, weekDay: trip.startDate.timeIntervalSince1970))
                prevWeekday = weekday
            } else {
                let lastVal = viewModels.popLast()?.val ?? 0
                viewModels.append(TripChartViewModel.init(val: lastVal + val, weekDay: trip.startDate.timeIntervalSince1970))
            }
        }
        
        /// Remove later
        viewModels.insert(TripChartViewModel.init(val: 5000, weekDay: Date().timeIntervalSince1970 - 86500), at: 0)
        viewModels.insert(TripChartViewModel.init(val: 6000, weekDay: Date().timeIntervalSince1970 - (86500 * 2)), at: 0)
        viewModels.insert(TripChartViewModel.init(val: 4500, weekDay: Date().timeIntervalSince1970 - (86500 * 3)), at: 0)
        
        
        let yVals = viewModels.map { (t) -> BarChartDataEntry in
            return BarChartDataEntry(x: t.weekDay, y: metric.convertFromMeters(t.val))
        }
        
        let set = BarChartDataSet(entries: yVals, label: "Current week")
        set.colors = ChartColorTemplates.material()
        
        let data = BarChartData(dataSet: set)
        data.barWidth = 80000
        
        return data
    }
}

struct TripChartViewModel {
    let val: Double
    let weekDay: TimeInterval
}

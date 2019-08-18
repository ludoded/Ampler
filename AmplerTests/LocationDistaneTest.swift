//
//  LocationDistaneTest.swift
//  AmplerTests
//
//  Created by Haik Ampardjian on 8/17/19.
//  Copyright © 2019 Haik Ampardjian. All rights reserved.
//

import XCTest
import CoreLocation

class LocationDistaneTest: XCTestCase {
    var locationDistance: LocationDistance!
    
    override func setUp() {
        locationDistance = LocationDistance()
    }
    
    func testCalculateDistance() {
        let coordinates = [CLLocationCoordinate2D(latitude: 46.403003, longitude: 30.745459),
                           CLLocationCoordinate2D(latitude: 46.403299, longitude: 30.743485)
        ]
        let distance = locationDistance.computeDistance(coordinates: coordinates)
        
        XCTAssertLessThanOrEqual(distance, 200, "Distance should be less 200 meters")
    }
    
    func testCalculateComplexDistance() {
        let coordinates = [CLLocationCoordinate2D(latitude: 46.403869, longitude: 30.743437),
                           CLLocationCoordinate2D(latitude: 46.403327, longitude: 30.743575),
                           CLLocationCoordinate2D(latitude: 46.403423, longitude: 30.743886),
                           CLLocationCoordinate2D(latitude: 46.403682, longitude: 30.744208),
                           CLLocationCoordinate2D(latitude: 46.403360, longitude: 30.744990)
        ]
        let distance = locationDistance.computeDistance(coordinates: coordinates)
        
        XCTAssertLessThanOrEqual(distance, 200, "Distance should be less 200 meters")
    }
    
    func testCalculateLongOdessaChisinauDistance() {
        let coordinates = [CLLocationCoordinate2D(latitude: 46.431756, longitude: 30.760956),
                           CLLocationCoordinate2D(latitude: 46.991959, longitude: 28.821989)
        ]
        let distance = locationDistance.computeDistance(coordinates: coordinates)
        
        XCTAssertGreaterThanOrEqual(distance, 150000, "Distance should be more than 150km")
        XCTAssertLessThanOrEqual(distance, 200000, "Distance should be less 200km")
    }
    
    func testCalculateEmptyDistance() {
        let distance = locationDistance.computeDistance(coordinates: [])
        
        XCTAssertEqual(distance, 0, "Distance should be 0 meters")
    }
    
    func testCalculateOneLocationDistance() {
        let coordinates = [CLLocationCoordinate2D(latitude: 46.403003, longitude: 30.745459)]
        let distance = locationDistance.computeDistance(coordinates: coordinates)
        
        XCTAssertEqual(distance, 0, "Distance should be 0 meters")
    }
}

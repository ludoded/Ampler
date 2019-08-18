//
//  LocationServiceTest.swift
//  AmplerTests
//
//  Created by Haik Ampardjian on 8/17/19.
//  Copyright © 2019 Haik Ampardjian. All rights reserved.
//

import XCTest
import CoreLocation

class LocationServiceTest: XCTestCase {
    var service: LocationService!
    
    override func setUp() {
        service = LocationService()
    }

    override func tearDown() {
        service = nil
    }
    
    func testLocationManagerSettings() {
        XCTAssertTrue(service.locationManager.desiredAccuracy == kCLLocationAccuracyBestForNavigation, "Location manager should have best accuracy enabled")
        XCTAssertLessThanOrEqual(service.locationManager.distanceFilter, 5, "Location manager's distance filter should be better or equal five")        
    }
}

func swizzle(foo: AnyClass, from: Selector, isClassMethod: Bool = false, body: () -> Void) {
    let get: (AnyClass?, Selector) -> Method? = isClassMethod ? class_getClassMethod : class_getInstanceMethod
    let originalMethod = get(foo, from)
    let swizzledMethod = get(foo, Selector("pmk_\(from)"))
    
    method_exchangeImplementations(originalMethod!, swizzledMethod!)
    body()
    method_exchangeImplementations(swizzledMethod!, originalMethod!)
}

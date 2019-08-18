//
//  TripSession.swift
//  AmplerTests
//
//  Created by Haik Ampardjian on 8/9/19.
//  Copyright © 2019 Haik Ampardjian. All rights reserved.
//

import XCTest

class TripSessionTest: XCTestCase {
    var session: TripSession!
    
    override func setUp() {
        session = TripSession()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testTripSessionHasIdleWhenInitiated() {
        XCTAssertEqual(session.state, TripSessionState.idle)
    }
    
    func testTripSessionHasDefaultStartDate() {
        XCTAssertNoThrow(try session.start())
        
        XCTAssertNotNil(session.startDate)
    }
    
    func testTripSessionHasStartedState() {
        XCTAssertNoThrow(try session.start())
        
        XCTAssertEqual(session.state, TripSessionState.started)
    }
    
    func testTripSessionHasSpecificStartDate() {
        let date = Date()
        XCTAssertNoThrow(try session.start(for: date))
        
        XCTAssertEqual(date, session.startDate!)
    }
    
    func testTripSessionStopStateWhenStopped() {
        XCTAssertNoThrow(try session.start())
        XCTAssertNoThrow(try session.stop())
        
        XCTAssertEqual(session.state, TripSessionState.finished)
    }
    
    func testTripSessionHasProperStopDateWhenStopped() {
        XCTAssertNoThrow(try session.start())
        XCTAssertNoThrow(try session.stop())
        
        XCTAssertNotNil(session.stopDate)
        XCTAssertGreaterThanOrEqual(session.stopDate!, session.startDate!)
    }
    
    func testCannotStartWhenStartedOrFinished() {
        XCTAssertNoThrow(try session.start(), "First start should not throw any error")
        XCTAssertThrowsError(try session.start(), "Can't start if session is started") { error in
            XCTAssertEqual(error as! TripSessionError, TripSessionError.alreadyStarted)
        }
        
        XCTAssertNoThrow(try session.stop())
        XCTAssertThrowsError(try session.start(), "Can't start if session is finished") { error in
            XCTAssertEqual(error as! TripSessionError, TripSessionError.alreadyFinished)
        }
    }
    
    func testCannotStopWhenFinished() {
        XCTAssertNoThrow(try session.start(), "First start should not throw any error")
        
        XCTAssertNoThrow(try session.stop())
        XCTAssertThrowsError(try session.stop(), "Can't stop if session is finished") { error in
            XCTAssertEqual(error as! TripSessionError, TripSessionError.alreadyFinished)
        }
    }
    
    // Mark: - Test Durations
    func testDurationIfNotStarted() {
        let duration = session.duration()
        XCTAssertTrue(duration.isNaN)
    }
    
    func testDurationIfNotFinished() {
        XCTAssertNoThrow(try session.start())
        
        let duration = session.duration()
        XCTAssertGreaterThan(duration, 0)
    }
    
    func testDurationWhenFinished() {
        XCTAssertNoThrow(try session.start())
        
        let beforeDate = Date()
        XCTAssertNoThrow(try session.stop())
        let afterDate = Date()
        
        let beforeTime = beforeDate.timeIntervalSince(session.startDate!)
        let afterTime = afterDate.timeIntervalSince(session.startDate!)
        
        let duration = session.duration()
        XCTAssertGreaterThan(duration, beforeTime)
        XCTAssertLessThanOrEqual(duration, afterTime)
    }
}

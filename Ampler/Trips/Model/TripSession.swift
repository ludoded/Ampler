//
//  TripSession.swift
//  Ampler
//
//  Created by Haik Ampardjian on 8/9/19.
//  Copyright © 2019 Haik Ampardjian. All rights reserved.
//

import Foundation

enum TripSessionError: Error, Equatable {
    case alreadyIdle
    case alreadyStarted
    case alreadyFinished
    case notStarted
    
    var localizedDescription: String {
        switch self {
        case .alreadyIdle:
            return "Session is already in idle"
        case .alreadyStarted:
            return "Session is already started"
        case .alreadyFinished:
            return "Session is already finished"
        case .notStarted:
            return "Session is not started yet"
        }
    }
}

enum TripSessionState: Int {
    case idle
    case started
    case finished
    
    func canChange(to state: TripSessionState) throws -> Bool {
        switch state {
        case .idle:
            throw TripSessionError.alreadyIdle
        case .started:
            switch self {
            case .idle: return true
            case .started: throw TripSessionError.alreadyStarted
            case .finished: throw TripSessionError.alreadyFinished
            }
        case .finished:
            switch self {
            case .idle: throw TripSessionError.notStarted
            case .started: return true
            case .finished: throw TripSessionError.alreadyFinished
            }
        }
    }
}

final class TripSession {
    var state: TripSessionState
    var startDate: Date?
    var stopDate: Date?
    let locationService: LocationService
    
    init() {
        self.state = .idle
        self.locationService = LocationService()
    }
    
    func start(for date: Date = Date()) throws {
        guard try state.canChange(to: .started) else { return }
        
        startDate = date
        state = .started
        locationService.startUpdatingLocation()
    }
    
    func stop() throws {
        guard try state.canChange(to: .finished) else { return }
        
        stopDate = Date()
        state = .finished
        locationService.stopUpdatingLocation()
    }
    
    func duration() -> TimeInterval {
        switch state {
        case .idle:
            return .nan
        case .started:
            let date = Date()
            return date.timeIntervalSince(startDate!)
        case .finished:
            return stopDate!.timeIntervalSince(startDate!)
        }
    }
}

//
//  TripModel.swift
//  Ampler
//
//  Created by Haik Ampardjian on 8/18/19.
//  Copyright © 2019 Haik Ampardjian. All rights reserved.
//

import Foundation

final class TripModel {
    func saveTrip(session: TripSession) {
        guard let moc = PersistentStoreManager.shared.moc else { fatalError() }
        
        moc.performChangesAndWait {
            Trip.insert(into: moc, from: session)
        }
    }
}

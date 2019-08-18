//
//  LocationService.swift
//  Ampler
//
//  Created by Haik Ampardjian on 8/17/19.
//  Copyright © 2019 Haik Ampardjian. All rights reserved.
//

import Foundation
import CoreLocation

final class LocationService: NSObject {
    let locationManager: CLLocationManager
    var locationDataArray: [CLLocation]
    var useFilter: Bool
    var isUpdatingLocation: Bool
    
    override init() {
        isUpdatingLocation = false
        locationManager = CLLocationManager()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 5
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationDataArray = [CLLocation]()
        
        useFilter = true
        
        super.init()
        
        locationManager.delegate = self
    }
    
    func startUpdatingLocation() {
        if CLLocationManager.locationServicesEnabled(){
            locationManager.startUpdatingLocation()
        } else {
            //tell view controllers to show an alert
            showTurnOnLocationServiceAlert()
        }
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func showTurnOnLocationServiceAlert(){
        NotificationCenter.default.post(name: Notification.Name(rawValue:"showTurnOnLocationServiceAlert"), object: nil)
    }
    
    func notifiyDidUpdateLocation(newLocation:CLLocation){
        NotificationCenter.default.post(name: Notification.Name(rawValue:"didUpdateLocation"),
                                        object: nil,
                                        userInfo: ["location" : newLocation,
                                                   "locationData": locationDataArray])
    }
    
    func filterAndAddLocation(_ location: CLLocation) -> Bool{
        let age = -location.timestamp.timeIntervalSinceNow
        
        if age > 10 {
            print("Locaiton is old.")
            return false
        }
        
        if location.horizontalAccuracy < 0 {
            print("Latitidue and longitude values are invalid.")
            return false
        }
        
        if location.horizontalAccuracy > 100 {
            print("Accuracy is too low.")
            return false
        }
        
        print("Location quality is good enough.")
        locationDataArray.append(location)
        
        return true
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        isUpdatingLocation = false
    }
    
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        isUpdatingLocation = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        isUpdatingLocation = true
        
        if let newLocation = locations.last{
            print("(\(newLocation.coordinate.latitude), \(newLocation.coordinate.latitude))")
            
            var locationAdded: Bool
            if useFilter{
                locationAdded = filterAndAddLocation(newLocation)
            } else {
                locationDataArray.append(newLocation)
                locationAdded = true
            }
            
            if locationAdded{
                notifiyDidUpdateLocation(newLocation: newLocation)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if (error as NSError).domain == kCLErrorDomain && (error as NSError).code == CLError.Code.denied.rawValue{
            //User denied your app access to location information.
            showTurnOnLocationServiceAlert()
        }
    }
}

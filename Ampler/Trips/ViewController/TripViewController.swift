//
//  TripViewController.swift
//  Ampler
//
//  Created by Haik Ampardjian on 8/17/19.
//  Copyright © 2019 Haik Ampardjian. All rights reserved.
//

import UIKit
import MapKit

final class TripViewController: UIViewController {
    @IBOutlet fileprivate weak var mapView: MKMapView!
    @IBOutlet fileprivate weak var startTripButton: UIButton!
    
    var userAnnotationImage: UIImage!
    var userAnnotation: UserAnnotation?
    var accuracyRangeCircle: MKCircle
    var polyline: MKPolyline?
    var isZooming: Bool?
    var isBlockingAutoZoom: Bool?
    var zoomBlockingTimer: Timer?
    var didInitialZoom: Bool?
    
    var tripSession: TripSession?
    
    @IBAction fileprivate func toggleTripState(_ sender: Any) {
        if let tripSession = tripSession {
            try? tripSession.stop()
            
            // Stop session
            let model = TripModel()
            model.saveTrip(session: tripSession)
            
            self.tripSession = nil
            startTripButton.setTitle("Start Trip", for: .normal)
        } else {
            tripSession = TripSession()
            try? tripSession?.start()
            startTripButton.setTitle("Stop Trip", for: .normal)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.userAnnotationImage = UIImage(named: "user_position_ball")
        self.accuracyRangeCircle = MKCircle(center: CLLocationCoordinate2D.init(latitude: 41.887, longitude: -87.622), radius: 50)
        self.didInitialZoom = false
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        self.mapView.showsUserLocation = false
        self.mapView.addOverlay(accuracyRangeCircle)
        
        /// Handle observers from Location services
        NotificationCenter.default.addObserver(self, selector: #selector(updateMap(notification:)), name: Notification.Name(rawValue:"didUpdateLocation"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showTurnOnLocationServiceAlert(notification:)), name: Notification.Name(rawValue:"showTurnOnLocationServiceAlert"), object: nil)
    }
    
    @objc func showTurnOnLocationServiceAlert(notification: NSNotification) {
        let alert = UIAlertController(title: "Turn on Location Service", message: "To use location tracking feature of the app, please turn on the location service from the Settings app.", preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            let settingsUrl = URL(string: UIApplication.openSettingsURLString)
            if let url = settingsUrl {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        alert.addAction(settingsAction)
        alert.addAction(cancelAction)
        
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc func updateMap(notification: NSNotification) {
        if let userInfo = notification.userInfo{
            
            updatePolylines(locationData: userInfo["locationData"] as! [CLLocation])
            
            if let newLocation = userInfo["location"] as? CLLocation {
                zoomTo(location: newLocation)
            }
        }
    }
    
    private func updatePolylines(locationData: [CLLocation]) {
        var coordinateArray = [CLLocationCoordinate2D]()
        
        for loc in locationData {
            coordinateArray.append(loc.coordinate)
        }
        
        self.clearPolyline()
        
        self.polyline = MKPolyline(coordinates: coordinateArray, count: coordinateArray.count)
        self.mapView.addOverlay(polyline!)
        
    }
    
    private func clearPolyline() {
        if self.polyline != nil {
            self.mapView.removeOverlay(self.polyline!)
            self.polyline = nil
        }
    }
    
    private func zoomTo(location: CLLocation) {
        if self.didInitialZoom == false {
            let coordinate = location.coordinate
            let region = MKCoordinateRegion.init(center: coordinate, latitudinalMeters: 300, longitudinalMeters: 300)
            self.mapView.setRegion(region, animated: false)
            self.didInitialZoom = true
        }
        
        if self.isBlockingAutoZoom == false {
            self.isZooming = true
            self.mapView.setCenter(location.coordinate, animated: true)
        }
        
        var accuracyRadius = 50.0
        if location.horizontalAccuracy > 0 {
            if location.horizontalAccuracy > accuracyRadius {
                accuracyRadius = location.horizontalAccuracy
            }
        }
        
        self.mapView.removeOverlay(self.accuracyRangeCircle)
        self.accuracyRangeCircle = MKCircle(center: location.coordinate, radius: accuracyRadius as CLLocationDistance)
        self.mapView.addOverlay(self.accuracyRangeCircle)
        
        if self.userAnnotation != nil {
            self.mapView.removeAnnotation(self.userAnnotation!)
        }
        
        self.userAnnotation = UserAnnotation(coordinate: location.coordinate, title: "", subtitle: "")
        self.mapView.addAnnotation(self.userAnnotation!)
    }
}

extension TripViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay === self.accuracyRangeCircle{
            let circleRenderer = MKCircleRenderer(circle: overlay as! MKCircle)
            circleRenderer.fillColor = UIColor(white: 0.0, alpha: 0.25)
            circleRenderer.lineWidth = 0
            return circleRenderer
        } else {
            let polylineRenderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
            polylineRenderer.strokeColor = UIColor(rgb:0x1b60fe)
            polylineRenderer.alpha = 0.5
            polylineRenderer.lineWidth = 5.0
            return polylineRenderer
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        } else {
            let identifier = "UserAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            if annotationView != nil{
                annotationView!.annotation = annotation
            } else {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }
            annotationView!.canShowCallout = false
            annotationView!.image = self.userAnnotationImage
            
            return annotationView
        }
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        if self.isZooming == true{
            self.isZooming = false
            self.isBlockingAutoZoom = false
        } else {
            self.isBlockingAutoZoom = true
            if let timer = self.zoomBlockingTimer {
                if timer.isValid{
                    timer.invalidate()
                }
            }
            self.zoomBlockingTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false, block: { (Timer) in
                self.zoomBlockingTimer = nil
                self.isBlockingAutoZoom = false;
            })
        }
    }
}

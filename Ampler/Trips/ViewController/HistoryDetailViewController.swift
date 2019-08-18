//
//  HistoryDetailViewController.swift
//  Ampler
//
//  Created by Haik Ampardjian on 8/18/19.
//  Copyright © 2019 Haik Ampardjian. All rights reserved.
//

import UIKit
import MapKit

final class HistoryDetailViewController: UIViewController {
    @IBOutlet fileprivate weak var mapView: MKMapView!
    
    var trip: Trip!
    var model: HistoryDetailModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        model = HistoryDetailModel(with: trip)
        
        let coords = model.coordinatesForPolyline
        let polyline = MKPolyline(coordinates: coords, count: coords.count)
        mapView.addOverlay(polyline)
        
        zoomToTrip()
    }
    
    private func zoomToTrip() {
        let center = model.centerLocation
        let distance = model.totalDistance
        let region = MKCoordinateRegion(center: center, latitudinalMeters: distance, longitudinalMeters: distance)
        mapView.setRegion(region, animated: false)
    }
}

extension HistoryDetailViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        polylineRenderer.strokeColor = UIColor(rgb: 0x1b60fe)
        polylineRenderer.alpha = 0.5
        polylineRenderer.lineWidth = 5.0
        return polylineRenderer
    }
}

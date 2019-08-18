//
//  UserAnnotation.swift
//  Ampler
//
//  Created by Haik Ampardjian on 8/17/19.
//  Copyright © 2019 Haik Ampardjian. All rights reserved.
//

import Foundation
import MapKit

class UserAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    
    convenience override init() {
        self.init(coordinate:CLLocationCoordinate2DMake(41.887, -87.622), title:"", subtitle:"")
    }
    
    required init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        
        super.init()
    }
}

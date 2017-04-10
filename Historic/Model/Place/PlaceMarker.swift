//
//  Place.swift
//  Historic
//
//  Created by Kirill Varlamov on 07.04.17.
//  Copyright © 2017 Kirill Varlamov. All rights reserved.
//

import UIKit
import GoogleMaps

class PlaceMarker: NSObject, GMUClusterItem {
    
    var position: CLLocationCoordinate2D
    var title: String
    
    
    init(position: CLLocationCoordinate2D, title: String) {
        self.position = position
        self.title = title
    }
}

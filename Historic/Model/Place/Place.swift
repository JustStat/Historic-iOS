//
//  Place.swift
//  Historic
//
//  Created by Kirill Varlamov on 07.04.17.
//  Copyright © 2017 Kirill Varlamov. All rights reserved.
//

import UIKit
import GoogleMaps

struct PlaceImage {
    var thumb : String?
    var original : String?
}

class Place: NSObject, GMUClusterItem {
    var id : Int = 0
    var position: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var name: String = ""
    var image: PlaceImage
    
    init(id: Int, position: CLLocationCoordinate2D, name: String, image: PlaceImage)
    {
        self.id = id
        self.position = position
        self.name = name
        self.image = image
    }
}

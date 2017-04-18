//
//  PlaceDetailed.swift
//  Historic
//
//  Created by Kirill Varlamov on 12.04.17.
//  Copyright © 2017 Kirill Varlamov. All rights reserved.
//

import UIKit

class PlaceDetailed: Place {
    var desc: String
    var images: Array<PlaceImage>

    init(id: Int, position: CLLocationCoordinate2D, name: String, image: PlaceImage, desc: String, images: Array<PlaceImage>) {
        self.desc = desc
        self.images = images
        super.init(id: id, position: position, name: name, image: image)
    }
    
}

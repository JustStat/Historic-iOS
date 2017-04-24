//
//  Place.swift
//  Historic
//
//  Created by Kirill Varlamov on 07.04.17.
//  Copyright © 2017 Kirill Varlamov. All rights reserved.
//

import UIKit
import GoogleMaps
import RealmSwift
import Realm

class PlaceImage: Object {
    dynamic var thumb : String?
    dynamic var original : String?
    
    required init() {
        super.init()
    }
    
    convenience init(thumb: String, original: String) {
        self.init()
        self.thumb = thumb
        self.original = original
    }
    
    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }
    
    required init(value: Any, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }
}

class Place: Object, GMUClusterItem {
    dynamic var id : Int = 0
    dynamic var position: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(
            latitude: lat,
            longitude: lon)
    }
    dynamic var name: String = ""
    dynamic var image: PlaceImage!
    dynamic var desc: String = ""
    var images = List<PlaceImage>()
    dynamic var lat: Double = 0
    dynamic var lon: Double = 0
    
    
    required init() {
        self.image = PlaceImage()
        super.init()
    }
    
    convenience init(id: Int, position: CLLocationCoordinate2D, name: String, image: PlaceImage, desc: String, images: List<PlaceImage>)
    {
        self.init()
        self.id = id
        self.name = name
        self.image = image
        self.desc = desc
        self.images = images
        self.lat = position.latitude
        self.lon = position.longitude
    }
    
    
    override static func primaryKey() -> String? {
       return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["position"]
    }
    
    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        self.image = PlaceImage()
        super.init(realm: realm, schema: schema)
    }
    
    required init(value: Any, schema: RLMSchema) {
        self.image = PlaceImage()
        super.init(value: value, schema: schema)
    }
}

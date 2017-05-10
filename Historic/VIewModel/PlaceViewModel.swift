//
//  PlaceViewModel.swift
//  Historic
//
//  Created by Kirill Varlamov on 06.05.17.
//  Copyright © 2017 Kirill Varlamov. All rights reserved.
//

import RealmSwift
import SwiftyJSON

class PlaceViewModel: NSObject {
    var places: Results<Place>!
    let realm = try! Realm()
    
    func loadPlacesFromServer(filter: String, completion: @escaping ((Void) -> Void)) {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let url = URL(string: "http://62.109.7.158/api/places/")!
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                let json = JSON(data: data!)
                var places: Array<Place> = []
                for i in 0..<json.count {
                    let placeInfo = json[i]
                    print(placeInfo)
                    let images = List<PlaceImage>()
                    let imagesJson = placeInfo["images"].array
                    if placeInfo["main_thumb"].string == nil || placeInfo["main_full"].string == nil {
                        continue
                    }
                    for image in imagesJson! {
                        if image["full"].string != nil && image["thumbnail"].string != nil {
                            images.append(PlaceImage(thumb: image["full"].string!, original: image["thumbnail"].string!))
                        }
                    }
                    let place = Place(id: placeInfo["id"].int!, position: CLLocationCoordinate2DMake(CLLocationDegrees(placeInfo["locations"][0]["latitude"].float!), CLLocationDegrees(placeInfo["locations"][0]["longitude"].float!)), name: placeInfo["name"].string!, image: PlaceImage(thumb: placeInfo["main_thumb"].string!, original: placeInfo["main_full"].string!), desc: placeInfo["description"].string!, images: images)
                    places.append(place)
                    
                }
                DispatchQueue.main.async {
                    try! self.realm.write {
                        self.realm.deleteAll()
                        for place in places {
                            self.realm.add(place)
                        }
                    }
                    self.getPlacesFormCache(filter: filter, completion: completion)
                }
            }
            
        })
        task.resume()
    }
    
    func getPlacesFormCache(filter: String, completion: @escaping ((Void) -> Void)) {
        if filter == "" {
            places = realm.objects(Place.self)
        } else {
            places = realm.objects(Place.self).filter(NSPredicate(format: "name CONTAINS %@", filter))
        }
        DispatchQueue.main.async {
            completion()
        }
    }
    
    func needUpdate() -> Bool {
        return false
    }
    
    func getPlaces(filter: String, completionHandler: @escaping ((Void) -> Void)) {
        if needUpdate() {
            loadPlacesFromServer(filter: filter, completion: completionHandler)
        } else {
            getPlacesFormCache(filter: filter, completion: completionHandler)
        }
    }

}

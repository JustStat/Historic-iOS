//
//  PlaceViewModel.swift
//  Historic
//
//  Created by Kirill Varlamov on 06.05.17.
//  Copyright © 2017 Kirill Varlamov. All rights reserved.
//

import RealmSwift
import SwiftyJSON

enum FilterState: Int {
    case Alphabetic
    case Near
}

class PlaceViewModel: NSObject {
    var places = [Place]()
    let realm = try! Realm()
    var query = ""
    var filter = FilterState.Alphabetic
    var location = CLLocation(latitude: 0, longitude: 0)
    
    func loadPlacesFromServer(completion: @escaping ((Void) -> Void)) {
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
                    UserDefaults.standard.set(false, forKey: "NeedUpdate")
                    self.getPlacesFormCache(completion: completion)
                }
            }
            
        })
        task.resume()
    }
    
    func getPlacesFormCache(completion: @escaping ((Void) -> Void)) {
        if query == "" {
            places = Array<Place>(realm.objects(Place.self))
        } else {
            places = Array<Place>(realm.objects(Place.self).filter(NSPredicate(format: "sName CONTAINS %@", query.lowercased())))
        }
        switch self.filter {
        case .Alphabetic:
            places = places.sorted(by: { (first, second) -> Bool in
                return first.name < second.name
            })
            break
        case .Near:
            print(location)
            places = places.sorted(by: { (first, second) -> Bool in
                let firstPos = location.distance(from: CLLocation(latitude: first.lat, longitude: first.lon))
                print(firstPos)
                let secondPos = location.distance(from: CLLocation(latitude: second.lat, longitude: second.lon))
                print(secondPos)
                return firstPos > secondPos
            })
            break
        }
        DispatchQueue.main.async {
            completion()
        }
    }
    
    func getPlaces(completionHandler: @escaping ((Void) -> Void)) {
        if UserDefaults.standard.bool(forKey: "NeedUpdate") {
            loadPlacesFromServer(completion: completionHandler)
        } else {
            getPlacesFormCache(completion: completionHandler)
        }
    }

}

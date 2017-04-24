//
//  MapViewController.swift
//  Historic
//
//  Created by Kirill Varlamov on 27.03.17.
//  Copyright © 2017 Kirill Varlamov. All rights reserved.
//

import UIKit
import GoogleMaps
import SwiftSpinner
import SwiftyJSON
import RealmSwift


class MapViewController: UIViewController, GMSMapViewDelegate, GMUClusterManagerDelegate {
    @IBOutlet weak var mapView: GMSMapView!
    private var clusterManager: GMUClusterManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadPlaces()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadPlaces() {
        SwiftSpinner.show("Загрузка данных", animated: true)
        var places: Array<Place> = []
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let url = URL(string: "http://62.109.7.158/api/places/")!
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
        
        
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            
            if error != nil {
                
                print(error!.localizedDescription)
                
            } else {
                let json = JSON(data: data!)
                for i in 0..<json["count"].int! {
                    let placeInfo = json["results"][i]
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
                DispatchQueue.main.sync() {
                    SwiftSpinner.hide()
                    print(realm.objects(Place.self).count)
                    for place in places {
                        try! realm.write() {
                            realm.add(place)
                        }
                    }
                    print(realm.objects(Place.self).count)
                    self.initMap();
                }
            }
            
        })
        task.resume()
    }

    
    func initMap() {
        let camera = GMSCameraPosition.camera(withLatitude: 43.10,
                                              longitude: 131.87, zoom: 12)
        mapView.camera = camera
        mapView.delegate = self
        
        do {
            if let styleURL = Bundle.main.url(forResource: "mapstyle", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
        
        initClasterization(cameraPos: camera)

    }
    
    func addMarkers() {
        let realm = try! Realm()
        let places = realm.objects(Place.self)
        print(places[0].lat)
        for place in places {
            print(place.lat)
            self.clusterManager.add(place)
        }
    }
    
    func initClasterization(cameraPos: GMSCameraPosition) {
        let iconGenerator = GMUDefaultClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(mapView: mapView,
                                                 clusterIconGenerator: iconGenerator)
        clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm,
                                           renderer: renderer)
        clusterManager.setDelegate(self, mapDelegate: self)
        addMarkers()
        clusterManager.cluster()
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        performSegue(withIdentifier: "showDetail", sender: self)
    }
    
    func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) -> Bool {
        let newCamera = GMSCameraPosition.camera(withTarget: cluster.position,
                                                 zoom: mapView.camera.zoom + 1)
        let update = GMSCameraUpdate.setCamera(newCamera)
        mapView.moveCamera(update)
        return true
    }
    
    func clusterManager(_ clusterManager: GMUClusterManager, didTap clusterItem: GMUClusterItem) -> Bool {
        performSegue(withIdentifier: "showDetail", sender: clusterItem)
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detail" {
            let controller = segue.destination as! LocationDetailViewController
            controller.placeId = (sender as! Place).id
            print((sender as! Place).id)
        }
    }

}

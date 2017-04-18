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

class MapViewController: UIViewController, GMSMapViewDelegate, GMUClusterManagerDelegate {
    @IBOutlet weak var mapView: GMSMapView!
    private var clusterManager: GMUClusterManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        initMap();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        SwiftSpinner.show("Загрузка карты", animated: true)
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let url = URL(string: "http://62.109.7.158/api/places/")!
        
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            
            if error != nil {
                
                print(error!.localizedDescription)
                
            } else {
                let json = JSON(data: data!)
                for i in 0..<json["count"].int! {
                    let placeInfo = json["results"][i]
                    let place = Place(id: placeInfo["id"].int!, position: CLLocationCoordinate2DMake(CLLocationDegrees(placeInfo["locations"][0]["latitude"].float!), CLLocationDegrees(placeInfo["locations"][0]["longitude"].float!)), name: placeInfo["name"].string!, image: PlaceImage(thumb: placeInfo["main_thumb"].string, original: placeInfo["main_full"].string))
                    self.clusterManager.add(place)
                }
                DispatchQueue.main.sync() {
                    SwiftSpinner.hide()
                    self.clusterManager.cluster()
                }
                
            }
            
        })
        task.resume()
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

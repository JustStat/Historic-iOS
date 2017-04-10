//
//  MapViewController.swift
//  Historic
//
//  Created by Kirill Varlamov on 27.03.17.
//  Copyright © 2017 Kirill Varlamov. All rights reserved.
//

import UIKit
import GoogleMaps

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
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 14.0)
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
        let marker = PlaceMarker(position: CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20), title: "Жележнодорожный вокзал")
        clusterManager.add(marker)
        
        let marker2 = PlaceMarker(position: CLLocationCoordinate2D(latitude: -33.70, longitude: 151.20), title: "Жележнодорожный вокзал")
        clusterManager.add(marker2)
        
        let marker3 = PlaceMarker(position: CLLocationCoordinate2D(latitude: -33.80, longitude: 151.20), title: "Жележнодорожный вокзал")
        clusterManager.add(marker3)
        
        let marker4 = PlaceMarker(position: CLLocationCoordinate2D(latitude: -33.90, longitude: 151.20), title: "Жележнодорожный вокзал")
        clusterManager.add(marker4)
        
        let marker5 = PlaceMarker(position: CLLocationCoordinate2D(latitude: -33.75, longitude: 151.20), title: "Жележнодорожный вокзал")
        clusterManager.add(marker5)
        
        let marker6 = PlaceMarker(position: CLLocationCoordinate2D(latitude: -33.73, longitude: 151.20), title: "Жележнодорожный вокзал")
        clusterManager.add(marker6)

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
        performSegue(withIdentifier: "showDetail", sender: self)
        return true
    }

}

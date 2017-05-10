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
import DropDown


class MapViewController: UIViewController, GMSMapViewDelegate, GMUClusterManagerDelegate {
    @IBOutlet weak var mapView: GMSMapView!
    private var clusterManager: GMUClusterManager!
    private var searchBar: UISearchBar!
    let placeViewModel = PlaceViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar = self.addSearchBar()
        initMap()
        updateCamera()
        updateMarkers()

//        let dropDown = DropDown(anchorView: navigationItem.leftBarButtonItem!)
//        dropDown.dataSource = ["Car", "Motorcycle", "Truck"]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func initMap() {
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
        
        initClasterization()

    }
    
    func updateCamera() {
        let camera = GMSCameraPosition.camera(withLatitude: 43.10,
                                              longitude: 131.87, zoom: 12)
        mapView.camera = camera
    }
    
    func updateMarkers() {
        SwiftSpinner.show("Загрузка данных", animated: true)
        placeViewModel.getPlaces(filter: self.searchBar.text!) { () in
            self.clusterManager.clearItems()
            for place in self.placeViewModel.places {
                print(place)
                self.clusterManager.add(place)
            }
            self.clusterManager.cluster()
            SwiftSpinner.hide()
        }
    }
    
    func initClasterization() {
        let iconGenerator = GMUDefaultClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(mapView: mapView,
                                                 clusterIconGenerator: iconGenerator)
        clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm,
                                           renderer: renderer)
        clusterManager.setDelegate(self, mapDelegate: self)
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
        if segue.identifier == "showDetail" {
            let controller = segue.destination as! LocationDetailViewController
            controller.placeId = Int((sender as! GMUClusterItem).placeId)
        }
    }
    
    override func donePressed() {
        searchBar.resignFirstResponder()
    }
    
    override func cancelPressed() {
        updateMarkers()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        updateMarkers()
    }
}

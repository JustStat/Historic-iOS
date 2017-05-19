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



class MapViewController: UIViewController, GMSMapViewDelegate, GMUClusterManagerDelegate, UITabBarControllerDelegate {
    @IBOutlet weak var mapView: GMSMapView!
    private var clusterManager: GMUClusterManager!
    private var searchBar: UISearchBar!
    let placeViewModel = PlaceViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.delegate = self
        
        searchBar = self.addSearchBar(offset: 30)
        initMap()
        updateCamera()
        getMarkers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateMap()
        searchBar.text = self.placeViewModel.query
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
        mapView.isMyLocationEnabled = true
        
        initClasterization()

    }
    
    func updateCamera() {
        let camera = GMSCameraPosition.camera(withLatitude: 43.10,
                                              longitude: 131.87, zoom: 12)
        mapView.camera = camera
    }
    
    func getMarkers() {
        SwiftSpinner.show("Загрузка данных", animated: true)
        placeViewModel.getPlaces(completionHandler: { () in
            self.updateMap()
            SwiftSpinner.hide()
        }, error: { () in
            let alert = UIAlertController(title: "Ошибка", message: "Не удалось загрузить данные", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Повторить", style: .default, handler: { (action) in
                self.getMarkers()
            }))
            SwiftSpinner.hide()
            self.present(alert, animated: true, completion: nil)
        })
    }
    
    func updateMap() {
        self.clusterManager.clearItems()
        for place in self.placeViewModel.places {
            print(place)
            self.clusterManager.add(place)
        }
        self.clusterManager.cluster()
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
        placeViewModel.query = ""
        getMarkers()
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        getMarkers()
        searchBar.resignFirstResponder()
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if tabBarController.selectedIndex == 1 {
            let vc = (viewController as! UINavigationController).viewControllers[0] as!MainCollectionViewController
            if vc.placeViewModel == nil {
                vc.placeViewModel = self.placeViewModel
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.placeViewModel.query = searchText
    }
}

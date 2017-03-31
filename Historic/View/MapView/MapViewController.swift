//
//  MapViewController.swift
//  Historic
//
//  Created by Kirill Varlamov on 27.03.17.
//  Copyright © 2017 Kirill Varlamov. All rights reserved.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController, GMSMapViewDelegate {
    @IBOutlet weak var mapView: GMSMapView!

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

        addMarkers(map: mapView)

    }
    
    func addMarkers(map: GMSMapView) {
        let markerView = PostView(frame: CGRect(origin: .zero, size: CGSize(width: 80, height: 80)))
        let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20))
        marker.iconView = markerView
        marker.title = "Жележнодорожный вокзал"
        marker.snippet = "Подробнее"
        marker.map = map
        
        let marker2 = GMSMarker(position: CLLocationCoordinate2D(latitude: -33.90, longitude: 151.20))
        marker2.iconView = markerView
        marker2.title = "Жележнодорожный вокзал"
        marker2.snippet = "Подробнее"
        marker2.map = map
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        performSegue(withIdentifier: "showDetail", sender: self)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

//
//  LocationViewModel.swift
//  Historic
//
//  Created by Kirill Varlamov on 18.05.17.
//  Copyright © 2017 Kirill Varlamov. All rights reserved.
//

import UIKit

class LocationViewModel: NSObject {
    let locationManager = CLLocationManager()
    init<delegate: CLLocationManagerDelegate>(delegate: delegate) {
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = delegate
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func getLocation() -> CLLocation {
        return locationManager.location!
    }
    
}

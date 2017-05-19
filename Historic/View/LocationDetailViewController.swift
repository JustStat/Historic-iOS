//
//  LocationDetailViewController.swift
//  Historic
//
//  Created by Kirill Varlamov on 24.03.17.
//  Copyright © 2017 Kirill Varlamov. All rights reserved.
//

import UIKit
import GoogleMaps
import SwiftyJSON
import SwiftSpinner
import RealmSwift
import Agrume

class LocationDetailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var imagesCollectionView: GalleryCollectionView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var mapView: GMSMapView!
    var placeId: Int = 0
    var place: Place!

    override func viewDidLoad() {
        super.viewDidLoad()
        getPlaceInfo()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        do {
            if let styleURL = Bundle.main.url(forResource: "mapstyle", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
//        SwiftSpinner.show("Загрузка", animated: true)
    }
    
    func getPlaceInfo() {
        let realm = try! Realm()
        place = realm.objects(Place.self).filter(NSPredicate(format: "placeId == \(placeId)", argumentArray: [])).first
        print(place)
        setInterface()

    }
    
    func setInterface() {
        self.mainImageView.sd_setImage(with: URL(string: place.image.original!), placeholderImage: UIImage(named: "DefaultImage"))
        self.descriptionTextView.text = place.desc
        self.imagesCollectionView.reloadData()
        self.navigationItem.title = place.name
        
        let camera = GMSCameraPosition.camera(withLatitude: place.lat,
                                              longitude: place.lon, zoom: 12)
        self.mapView.isMyLocationEnabled = true
        self.mapView.camera = camera
        
        let marker = GMSMarker()
        marker.position = place.position
        marker.map = mapView
    }
    
    // Mark: - CollectionViewDelegateMethods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if place != nil {
            return place.images.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "galleryCell", for: indexPath) as! GalleryCollectionViewCell
        cell.imageView.sd_setImage(with: URL(string: place.images[indexPath.row].thumb!), placeholderImage: UIImage(named: "DefaultImage"))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let agrume = Agrume(imageUrl: URL(string: place.images[indexPath.row].original!)!)
        agrume.showFrom(self)
        
    }
    
    @IBAction func closeButtonTap(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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

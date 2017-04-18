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

class LocationDetailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var imagesCollectionView: GalleryCollectionView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var mapView: GMSMapView!
    var placeId: Int = 0
    var place: PlaceDetailed!

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
        SwiftSpinner.show("Загрузка", animated: true)
    }
    
    func getPlaceInfo() {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let url = URL(string: "http://62.109.7.158/api/places/\(placeId)")!
        
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            
            if error != nil {
                
                print(error!.localizedDescription)
                
            } else {
                let json = JSON(data: data!)
                var images: Array<PlaceImage> = []
                let imagesJson = json["images"].array
                for image in imagesJson! {
                    images.append(PlaceImage(thumb: image["full"].string, original: image["thumbnail"].string))
                }
                let place = PlaceDetailed(id: json["id"].int!, position: CLLocationCoordinate2DMake(CLLocationDegrees(json["locations"][0]["latitude"].float!), CLLocationDegrees(json["locations"][0]["longitude"].float!)), name: json["name"].string!, image: PlaceImage(thumb: json["main_thumb"].string, original: json["main_full"].string), desc: json["description"].string!, images: images)
                DispatchQueue.main.sync() {
                    self.place = place
                    self.setInterface()
                    SwiftSpinner.hide()
                }
            }
            
        })
        task.resume()
    }
    
    func setInterface() {
        self.mainImageView.sd_setImage(with: URL(string: place.image.original!), placeholderImage: UIImage(named: "DefaultImage"))
        self.descriptionTextView.text = place.desc
        self.imagesCollectionView.reloadData()
        
        let camera = GMSCameraPosition.camera(withLatitude: 43.10,
                                              longitude: 131.87, zoom: 12)
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

//
//  MainCollectionViewController.swift
//  Historic
//
//  Created by Kirill Varlamov on 23.03.17.
//  Copyright © 2017 Kirill Varlamov. All rights reserved.
//

import UIKit
import AnimatedCollectionViewLayout
import SwiftyJSON
import SwiftSpinner
import RealmSwift

private let reuseIdentifier = "locationCell"

class MainCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var placesList: Array<Place> = []
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    var direction: UICollectionViewScrollDirection = .horizontal
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Turn on the paging mode for auto snaping support.
        collectionView?.isPagingEnabled = true
        self.modalTransitionStyle = .flipHorizontal
        
        if let layout = collectionView?.collectionViewLayout as? AnimatedCollectionViewLayout {
            layout.scrollDirection = direction
            layout.animator = LinearCardAttributesAnimator()
        }
        self.collectionView.backgroundColor = UIColor(patternImage: UIImage(named: "collectionBackground")!)
        getPlaces()
    }
    
    func getPlaces() {
        let realm = try! Realm()
        let places = realm.objects(Place.self)
        for place in places {
            print(place)
            self.placesList.append(place)
        }
        self.collectionView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(placesList.count)
        return placesList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: LocationCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! LocationCollectionViewCell
        print(placesList[indexPath.row])
        cell.locationImage.sd_setImage(with: URL(string: placesList[indexPath.row].image.original!), placeholderImage: UIImage(named: "DefaultImage"))
        cell.locationNameLabel.text = placesList[indexPath.row].name
        cell.clipsToBounds = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.bounds.width, height: view.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detail" {
            let controller = segue.destination as! LocationDetailViewController
            controller.placeId = placesList[(self.collectionView.indexPath(for: sender as! UICollectionViewCell))!.row].placeId
        }
    }
    
}

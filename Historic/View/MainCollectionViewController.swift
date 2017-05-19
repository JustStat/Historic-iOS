//
//  MainCollectionViewController.swift
//  Historic
//
//  Created by Kirill Varlamov on 23.03.17.
//  Copyright © 2017 Kirill Varlamov. All rights reserved.
//

import UIKit
import AnimatedCollectionViewLayout
import SwiftSpinner
import DropDown

private let reuseIdentifier = "locationCell"

class MainCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, CLLocationManagerDelegate {
    
    var placeViewModel: PlaceViewModel!
    private var searchBar: UISearchBar!
    var dropDown: DropDown!
    var locationViewModel: LocationViewModel!
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    var direction: UICollectionViewScrollDirection = .horizontal
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.isPagingEnabled = true
        locationViewModel = LocationViewModel(delegate: self)
        
        if let layout = collectionView?.collectionViewLayout as? AnimatedCollectionViewLayout {
            layout.scrollDirection = direction
            layout.animator = LinearCardAttributesAnimator()
        }
        self.collectionView.backgroundColor = UIColor(patternImage: UIImage(named: "collectionBackground")!)
        
        searchBar = self.addSearchBar(offset: 70)
        
        dropDown = DropDown(anchorView: navigationItem.rightBarButtonItem!)
        dropDown.dataSource = ["По алфавиту", "По дальности"]
        dropDown.dismissMode = .onTap
        dropDown.direction = .any
        dropDown.selectionAction = {(Index, String) in
            self.placeViewModel.filter = FilterState(rawValue: Index)!
            self.placeViewModel.location = self.locationViewModel.getLocation()
            self.getPlaces()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        searchBar.text = self.placeViewModel.query
        self.collectionView.reloadData()
    }
    
    func getPlaces() {
        placeViewModel.getPlaces(completionHandler: { () in
            self.collectionView.reloadData()
        }, error: { () in
            let alert = UIAlertController(title: "Ошибка", message: "Не удалось загрузить данные", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Повторить", style: .default, handler: { (action) in
                self.getPlaces()
            }))
            if self.placeViewModel.query != "" {
                alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
            }
            self.present(alert, animated: true, completion: nil)
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return placeViewModel.places.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: LocationCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! LocationCollectionViewCell
        cell.locationImage.sd_setImage(with: URL(string: placeViewModel.places[indexPath.row].image.original!), placeholderImage: UIImage(named: "DefaultImage"))
        cell.locationNameLabel.text = placeViewModel.places[indexPath.row].name
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
        if segue.identifier == "showDetail" {
            let controller = segue.destination as! LocationDetailViewController
            controller.placeId = placeViewModel.places[(self.collectionView.indexPath(for: sender as! UICollectionViewCell))!.row].placeId
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.placeViewModel.query = searchText
    }
    
    override func donePressed() {
        searchBar.resignFirstResponder()
    }
    
    override func cancelPressed() {
        placeViewModel.query = ""
        getPlaces()
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        getPlaces()
        searchBar.resignFirstResponder()
    }
    
    @IBAction func filterButtonTap(_ sender: Any) {
        dropDown.show()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.placeViewModel.location = locations[0]
        getPlaces()
    }
}

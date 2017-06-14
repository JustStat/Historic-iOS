//
//  MainTableViewTableViewController.swift
//  Historic
//
//  Created by Kirill Varlamov on 13.06.17.
//  Copyright © 2017 Kirill Varlamov. All rights reserved.
//

import UIKit
import SwiftSpinner
import DropDown
import FoldingCell

class MainTableViewTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    var placeViewModel: PlaceViewModel!
    private var searchBar: UISearchBar!
    var dropDown: DropDown!
    var locationViewModel: LocationViewModel!
    
    let kCloseCellHeight: CGFloat = 179
    let kOpenCellHeight: CGFloat = 488
    let kRowsCount = 10
    var cellHeights: [CGFloat] = []



    override func viewDidLoad() {
        super.viewDidLoad()
        locationViewModel = LocationViewModel(delegate: self)
        searchBar = self.addSearchBar(offset: 70)
        
        cellHeights = Array(repeating: kCloseCellHeight, count: placeViewModel.places.count)
        tableView.estimatedRowHeight = kCloseCellHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.backgroundColor = UIColor(patternImage: UIImage(named: "tableBackground")!)

        
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
        self.tableView.reloadData()
    }
    
    func getPlaces() {
        placeViewModel.getPlaces(completionHandler: { () in
            self.tableView.reloadData()
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

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeViewModel.places.count
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            let controller = segue.destination as! LocationDetailViewController
            controller.placeId = placeViewModel.places[(sender as! UIButton).tag].placeId
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

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoldingCell", for: indexPath) as! PlaceTableViewCell
        let place = placeViewModel.places[indexPath.row]
        cell.descTextView.text = place.desc
        cell.mainNameLabel.text = place.name
        cell.mainImage.sd_setImage(with: URL(string:place.image.original!), placeholderImage: UIImage(named: "DefaultImage"))
        cell.detailImage.sd_setImage(with: URL(string:place.image.original!), placeholderImage: UIImage(named: "DefaultImage"))
        cell.selectedAnimation(false, animated: false, completion:nil)
        cell.detailButton.tag = indexPath.row
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! FoldingCell
        
        if cell.isAnimating() {
            return
        }
        
        var duration = 0.0
        let cellIsCollapsed = cellHeights[indexPath.row] == kCloseCellHeight
        if cellIsCollapsed {
            cellHeights[indexPath.row] = kOpenCellHeight
            cell.selectedAnimation(true, animated: true, completion: nil)
            duration = 0.5
        } else {
            cellHeights[indexPath.row] = kCloseCellHeight
            cell.selectedAnimation(false, animated: true, completion: nil)
            duration = 0.8
        }
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: { () -> Void in
            tableView.beginUpdates()
            tableView.endUpdates()
        }, completion: nil)
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[indexPath.row]
    }

    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard case let cell as PlaceTableViewCell = cell else {
            return
        }
        
        cell.backgroundColor = .clear
        
        if cellHeights[indexPath.row] == kCloseCellHeight {
            cell.selectedAnimation(false, animated: false, completion:nil)
        } else {
            cell.selectedAnimation(true, animated: false, completion: nil)
        }
    }
    
    

}

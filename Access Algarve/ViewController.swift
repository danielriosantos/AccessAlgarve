//
//  ViewController.swift
//  Access Algarve Light
//
//  Created by Daniel Santos on 01/03/2018.
//  Copyright © 2018 Daniel Santos. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate {
    
    let locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    @IBOutlet weak var linkbutton: UIButton!
    @IBOutlet var searchBar: UISearchBar!
    
    var outlet: Outlet!
    
    // When button "Search" pressed
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        self.dismissSearchBar()
        self.performSegue(withIdentifier: "showSearchResultsSegue", sender: self)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissSearchBar))
        
        view.addGestureRecognizer(tap)
        
        self.locationManager.delegate = self
        self.searchBar.delegate = self
        
        //: Handle location
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.distanceFilter = 100
        
    }
    
    @objc func dismissSearchBar() {
        self.searchBar.endEditing(true)
        self.searchBar.isHidden = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            currentLocation = location
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueidentifier = segue.identifier else {return}
        if segueidentifier == "showMerchantDetailsSegue" {
            guard let outletDetailsViewController = segue.destination as? OutletDetailsViewController else {return}
            outletDetailsViewController.outlet = self.outlet
            outletDetailsViewController.currentLocation = currentLocation
            outletDetailsViewController.previousVC = "main"
        } else if segueidentifier == "showFavourites" {
            guard let favouritesViewController = segue.destination as? FavouritesViewController else {return}
            favouritesViewController.currentLocation = currentLocation
        } else if segueidentifier == "showSearchResultsSegue" {
            guard let searchResultsViewController = segue.destination as? SearchResultsViewController else {return}
            let searchTerm = searchBar.text
            searchResultsViewController.currentLocation = currentLocation
            searchResultsViewController.searchTerm = searchTerm
        } else {
            guard let outletsViewController = segue.destination as? OutletsViewController else {return}
            switch segueidentifier {
                case "showFoodDrinkVouchers":
                    outletsViewController.filterCategory = 1
                case "showLifestyleVouchers":
                    outletsViewController.filterCategory = 3
                default:
                    outletsViewController.filterCategory = 2
            }
            outletsViewController.currentLocation = currentLocation
        }
    }
    
    @IBAction func didUnwindFromVouchersController(_ segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func searchButtonClicked(_ sender: UIButton) {
        searchBar.isHidden = false
        self.searchBar.becomeFirstResponder()
    }
    
    @IBAction func buttonClicked(_ sender: Any) {
        
        getAPIResults(endpoint: "outlets/140", parameters: [:]) { data in
            do {
                //: Load the results
                self.outlet = try Outlet.decode(data: data)
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "showMerchantDetailsSegue", sender: self)
                }
            } catch {
                print("Error decoding Outlet Results data")
            }
        }
        
//        if let url = URL(string: "https://www.zoomarine.pt") {
//            UIApplication.shared.open(url, options: [:])
//        }
    }


}

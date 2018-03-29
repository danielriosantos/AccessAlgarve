//
//  ViewController.swift
//  Access Algarve Light
//
//  Created by Daniel Santos on 01/03/2018.
//  Copyright © 2018 Daniel Santos. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate, MKMapViewDelegate {
    
    var outlets = [Outlet]()
    var outletresultscontainer: OutletResults!
    var currentColor: UIColor!
    var currentPage = 1
    
    let locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    @IBOutlet weak var map: MKMapView!
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
        self.map.delegate = self
        
        //: Handle location
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.distanceFilter = 100
        
        //: Get user from database and update defaults
        loadUser()
        
        //: Proload Amenities
        getAPIResults(endpoint: "amenities", parameters: [:]) {data in
            let defaults = UserDefaults.standard
            defaults.set(data, forKey: "SavedAmenities")
        }
        
        map.showsUserLocation = true
        
    }
    
    @objc func dismissSearchBar() {
        self.searchBar.endEditing(true)
        self.searchBar.isHidden = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            self.currentLocation = location
            let userLocation = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
            let viewRegion = MKCoordinateRegionMakeWithDistance(userLocation, 30000, 30000)
            map.setRegion(viewRegion, animated: true)
            let circle = MKCircle(center: userLocation, radius: Double(10000))
            map.add(circle)
            //: Load first set of results
            loadResults(page: 1)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let circelOverLay = overlay as? MKCircle else {return MKOverlayRenderer()}
        
        let circleRenderer = MKCircleRenderer(circle: circelOverLay)
        //circleRenderer.strokeColor = .blue
        circleRenderer.fillColor = .blue
        circleRenderer.alpha = 0.05
        return circleRenderer
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
    
    private func loadResults(page: Int) -> Void {
        
        var params = ["page": String(page)]
        if currentLocation != nil {
            params["location"] = String(currentLocation.coordinate.latitude) + "," + String(currentLocation.coordinate.longitude)
            params["distance"] = String(10)
        }
        getAPIResults(endpoint: "outlets", parameters: params) { data in
            do {
                //: Load the results
                let outletresults = try OutletResults.decode(data: data)
                self.outlets.append(contentsOf: outletresults.data)
                self.outletresultscontainer = outletresults
                DispatchQueue.main.async {
                    for outlet in self.outlets {
                        //: Add pinpoint
                        let annotation = MKPointAnnotation()
                        let coordstring = outlet.gps.replacingOccurrences(of: " ", with: "")
                        if  coordstring != "" {
                            let coordsArr = coordstring.components(separatedBy: ",")
                            let outletLocation = CLLocationCoordinate2DMake(CLLocationDegrees(coordsArr[0])!, CLLocationDegrees(coordsArr[1])!)
                            annotation.coordinate = outletLocation
                            self.map.addAnnotation(annotation)
                        }
                    }
                    self.loadMoreResults()
                }
            } catch {
                print("Error decoding Outlet Results data")
            }
        }
        
    }
    
    private func loadMoreResults() {
        
        if currentPage < outletresultscontainer.last_page {
            currentPage = outletresultscontainer.current_page + 1
            loadResults(page: currentPage)
        }
        
    }


}

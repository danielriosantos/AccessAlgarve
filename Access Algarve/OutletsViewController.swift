//
//  VouchersViewController.swift
//  Access Algarve Light
//
//  Created by Daniel Santos on 02/03/2018.
//  Copyright © 2018 Daniel Santos. All rights reserved.
//

import UIKit
import CoreLocation
import SVProgressHUD

class OutletsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, CLLocationManagerDelegate {
    
    var outlets = [Outlet]()
    var outletresultscontainer: OutletResults!
    var filterCategory: Int!
    var currentColor: UIColor!
    var currentPage = 1
    let locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    @IBOutlet weak var outletsTableView: UITableView!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var currentButton: UIButton!
    @IBOutlet var searchBar: UISearchBar!
    
    //: Define Colors
    let pink = UIColor(red: 221.0/255.0, green: 78.0/255.0, blue: 149.0/255.0, alpha: 1.0)
    let orange = UIColor(red: 235.0/255.0, green: 128.0/255.0, blue: 0.0/255.0, alpha: 1.0)
    let blue = UIColor(red: 64.0/255.0, green: 191.0/255.0, blue: 239.0/255.0, alpha: 1.0)
    let white = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0)
    let invisible = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0)
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return outlets.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // set up cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "voucherCell", for: indexPath) as! ViewControllerTableViewCell
        DispatchQueue.main.async() {
            switch self.outlets[indexPath.row].offers[0].offer_category_id {
                case 1:
                    cell.voucherOfferName.textColor = self.pink
                    cell.voucherOfferType.textColor = self.pink
                case 3:
                    cell.voucherOfferName.textColor = self.orange
                    cell.voucherOfferType.textColor = self.orange
                default:
                    cell.voucherOfferName.textColor = self.blue
                    cell.voucherOfferType.textColor = self.blue
            }
            
            //: Handle distance
            let coordstring = self.outlets[indexPath.row].gps.replacingOccurrences(of: " ", with: "")
            var outletLocation: CLLocation!
            var distance: CLLocationDistance = 0
            var distanceMeters: CLLocationDistance = 0
            if  coordstring != "" {
                let coordsArr = coordstring.components(separatedBy: ",")
                outletLocation = CLLocation(latitude: CLLocationDegrees(coordsArr[0])!, longitude: CLLocationDegrees(coordsArr[1])!)
            }
            if outletLocation != nil {
                distance = outletLocation.distance(from: self.currentLocation) / 1000
                distanceMeters = outletLocation.distance(from: self.currentLocation)
            }
            
            cell.voucherCompanyLogo.image = nil
            cell.tag = indexPath.row
            if (self.outlets[indexPath.row].merchant != nil) {
                if cell.tag == indexPath.row {
                    cell.voucherCompanyLogo.downloadedFrom(link: "https://www.accessalgarve.com/images/logos/\(self.outlets[indexPath.row].merchant.id)-logo.png")
                }
            }
            cell.voucherOfferName.text = self.outlets[indexPath.row].name
            if (self.outlets[indexPath.row].offers[0].type != nil) {cell.voucherOfferType.text = self.outlets[indexPath.row].offers[0].type.name} else {cell.voucherOfferType.text = ""}
            if distance >= 1 {cell.voucherLocation.text = self.outlets[indexPath.row].city + " " + String(Int(distance.rounded(.toNearestOrEven))) + "km"} else {cell.voucherLocation.text = self.outlets[indexPath.row].city + " " + String(Int(distanceMeters.rounded(.toNearestOrEven))) + "m"}
            var offersavings: Double = 0
            for offer in self.outlets[indexPath.row].offers {
                offersavings += Double(offer.max_savings)!
            }
            cell.voucherEstimatedSavings.text = "ESTIMATED SAVINGS €" + String(offersavings)
        }
        
        // Check if the last row number is the same as the last current data element
        if indexPath.row == self.outlets.count - 1 {
            self.loadMoreResults()
        }
        
        return cell
    }
    
    // When button "Search" pressed
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        self.dismissSearchBar()
        self.performSegue(withIdentifier: "showSearchResultsSegue", sender: self)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissSearchBar))
        
        //view.addGestureRecognizer(tap)
        
        self.outletsTableView.delegate = self
        self.outletsTableView.dataSource = self
        self.searchBar.delegate = self
        self.locationManager.delegate = self
        
        //: Change button collours depending on button pressed
        switch Int(filterCategory) {
            case 1:
                currentButton.setImage(UIImage(named: "food&drink-button-small"), for: .normal)
                outletsTableView.separatorColor = pink
                currentColor = pink
            case 3:
                currentButton.setImage(UIImage(named: "lifestyle-button-small"), for: .normal)
                outletsTableView.separatorColor = orange
                currentColor = orange
            default:
                currentButton.setImage(UIImage(named: "activities-button-small"), for: .normal)
                outletsTableView.separatorColor = blue
                currentColor = blue
        }
        
        //: Handle location
        locationManager.startUpdatingLocation()
        locationManager.distanceFilter = 100
        
        //: Initiate loader
        //setLoadingScreen()
        DispatchQueue.main.async {
            self.outletsTableView.separatorColor = self.invisible
            SVProgressHUD.show(withStatus: "Loading")
        }
        
        //: Load first set of results
        loadResults(page: 1)
        
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.dismissSearchBar()
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
        if segue.identifier == "viewOfferSegue" {
            if let indexPath = outletsTableView.indexPathForSelectedRow {
                let selectedRow = indexPath.row
                guard let voucherDetailsViewController = segue.destination as? OutletDetailsViewController else {return}
                voucherDetailsViewController.outlet = outlets[selectedRow]
                voucherDetailsViewController.currentLocation = currentLocation
                voucherDetailsViewController.previousVC = "vouchers"
            }
        } else if segue.identifier == "viewOutletsLocationSegue" {
            guard let outletsLocationNavigationViewController = segue.destination as? UINavigationController else {return}
            guard let outletsLocationViewController = outletsLocationNavigationViewController.topViewController as? OutletsLocationViewController else {return}
            outletsLocationViewController.outlets = self.outlets
            outletsLocationViewController.outletresultscontainer = self.outletresultscontainer
            outletsLocationViewController.currentLocation = self.currentLocation
        } else if segue.identifier == "showSearchResultsSegue" {
            guard let searchResultsViewController = segue.destination as? SearchResultsViewController else {return}
            let searchTerm = searchBar.text
            searchResultsViewController.currentLocation = currentLocation
            searchResultsViewController.searchTerm = searchTerm
        } else if segue.identifier == "showFavourites" {
            guard let favouritesViewController = segue.destination as? FavouritesViewController else {return}
            favouritesViewController.currentLocation = currentLocation
        }
    }
    
    @IBAction func didUnwindFromVoucherDetailsController(_ segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func searchButtonClicked(_ sender: UIButton) {
        searchBar.isHidden = false
        self.searchBar.becomeFirstResponder()
    }
    
    private func loadResults(page: Int) -> Void {
        
        let selectedcategory = String(filterCategory)
        var params = ["category_id": selectedcategory, "page": page] as [String:Any]
        if currentLocation != nil {
            params["location"] = String(currentLocation.coordinate.latitude) + "," + String(currentLocation.coordinate.longitude)
        }
        getAPIResults(endpoint: "outlets", parameters: params) { data in
            do {
                //: Load the results
                let outletresults = try OutletResults.decode(data: data)
                self.outlets.append(contentsOf: outletresults.data)
                self.outletresultscontainer = outletresults
                DispatchQueue.main.async {
                    self.outletsTableView.reloadData()
                    //self.removeLoadingScreen()
                    self.outletsTableView.separatorColor = self.currentColor
                    SVProgressHUD.dismiss()
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

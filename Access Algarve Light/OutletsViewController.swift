//
//  VouchersViewController.swift
//  Access Algarve Light
//
//  Created by Daniel Santos on 02/03/2018.
//  Copyright © 2018 Daniel Santos. All rights reserved.
//

import UIKit
import CoreLocation

class OutletsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    var outlets = [Outlet]()
    var outletresultscontainer: OutletResults!
    var filterCategory: Int!
    var currentColor: UIColor!
    var currentPage = 1
    let locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    @IBOutlet weak var outletsTableView: UITableView!
    let loadingView = UIView()
    let spinner = UIActivityIndicatorView()
    let loadingLabel = UILabel()
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var currentButton: UIButton!
    
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
            
            if (self.outlets[indexPath.row].merchant != nil) {cell.voucherCompanyLogo.downloadedFrom(link: "https://www.accessalgarve.com/images/logos/\(self.outlets[indexPath.row].merchant.id)-logo.png")}
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
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.outletsTableView.delegate = self
        self.outletsTableView.dataSource = self
        self.locationManager.delegate = self
        
        //: Change button collours depending on button pressed
        switch Int(filterCategory) {
            case 1:
                backButton.setImage(UIImage(named: "back-arrow-pink"), for: .normal)
                currentButton.setImage(UIImage(named: "food&drink-button-small"), for: .normal)
                outletsTableView.separatorColor = pink
                currentColor = pink
            case 3:
                backButton.setImage(UIImage(named: "back-arrow-orange"), for: .normal)
                currentButton.setImage(UIImage(named: "lifestyle-button-small"), for: .normal)
                outletsTableView.separatorColor = orange
                currentColor = orange
            default:
                backButton.setImage(UIImage(named: "back-arrow-blue"), for: .normal)
                currentButton.setImage(UIImage(named: "activities-button-small"), for: .normal)
                outletsTableView.separatorColor = blue
                currentColor = blue
        }
        
        //: Handle location
        locationManager.startUpdatingLocation()
        locationManager.distanceFilter = 100
        
        //: Initiate loader
        setLoadingScreen()
        
        //: Load first set of results
        loadResults(page: 1)
        
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
        }
    }
    
    @IBAction func didUnwindFromVoucherDetailsController(_ segue: UIStoryboardSegue) {
        
    }
    
    private func loadResults(page: Int) -> Void {
        
        let selectedcategory = String(filterCategory)
        var params = ["category_id": selectedcategory, "page": String(page)]
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
                    self.removeLoadingScreen()
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
    
    // Set the activity indicator into the main view
    private func setLoadingScreen() {
        
        //Hide the tableView
        outletsTableView.separatorColor = invisible
        
        // Sets the view which contains the loading text and the spinner
        let width: CGFloat = 120
        let height: CGFloat = 30
        let x = (outletsTableView.frame.width / 2) - (width / 2)
        let y = (outletsTableView.frame.height / 2) - (height / 2)
        loadingView.frame = CGRect(x: x, y: y, width: width, height: height)
        
        // Sets loading text
        loadingLabel.textColor = .gray
        loadingLabel.textAlignment = .center
        loadingLabel.text = "Loading..."
        loadingLabel.frame = CGRect(x: 0, y: 0, width: 140, height: 30)
        
        // Sets spinner
        spinner.activityIndicatorViewStyle = .gray
        spinner.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        spinner.startAnimating()
        
        // Adds text and spinner to the view
        loadingView.addSubview(spinner)
        loadingView.addSubview(loadingLabel)
        
        outletsTableView.addSubview(loadingView)
        
    }
    
    // Remove the activity indicator from the main view
    private func removeLoadingScreen() {
        
        // Hides and stops the text and the spinner
        spinner.stopAnimating()
        spinner.isHidden = true
        loadingLabel.isHidden = true
        outletsTableView.separatorColor = currentColor
        
    }
    
}

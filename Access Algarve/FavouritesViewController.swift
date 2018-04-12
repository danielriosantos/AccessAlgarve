//
//  FavouritesViewController.swift
//  Access Algarve Light
//
//  Created by Daniel Santos on 25/03/2018.
//  Copyright © 2018 Daniel Santos. All rights reserved.
//

import UIKit
import CoreLocation

class FavouritesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {

    var user: User!
    var currentColor: UIColor!
    let locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocation!
    @IBOutlet weak var outletsTableView: UITableView!
    @IBOutlet weak var totalSavingsLabel: UILabel!
    
    //: Define Colors
    let pink = UIColor(red: 221.0/255.0, green: 78.0/255.0, blue: 149.0/255.0, alpha: 1.0)
    let orange = UIColor(red: 235.0/255.0, green: 128.0/255.0, blue: 0.0/255.0, alpha: 1.0)
    let blue = UIColor(red: 64.0/255.0, green: 191.0/255.0, blue: 239.0/255.0, alpha: 1.0)
    let white = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0)
    let invisible = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0)
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return user.favourites.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // set up cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "voucherCell", for: indexPath) as! ViewControllerTableViewCell
        DispatchQueue.main.async() {
            switch self.user.favourites[indexPath.row].outlet.offers[0].offer_category_id {
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
            let coordstring = self.user.favourites[indexPath.row].outlet.gps.replacingOccurrences(of: " ", with: "")
            var outletLocation: CLLocation!
            var distance: CLLocationDistance = 0
            var distanceMeters: CLLocationDistance = 0
            if  coordstring != "" {
                let coordsArr = coordstring.components(separatedBy: ",")
                outletLocation = CLLocation(latitude: CLLocationDegrees(coordsArr[0])!, longitude: CLLocationDegrees(coordsArr[1])!)
            }
            if outletLocation != nil && self.currentLocation != nil {
                distance = outletLocation.distance(from: self.currentLocation) / 1000
                distanceMeters = outletLocation.distance(from: self.currentLocation)
            } else {
                distance = 0
                distanceMeters = 0
            }
            
            if (self.user.favourites[indexPath.row].outlet.merchant != nil) {cell.voucherCompanyLogo.downloadedFrom(link: "https://www.accessalgarve.com/images/logos/\(self.user.favourites[indexPath.row].outlet.merchant.id)-logo.png")}
            cell.voucherOfferName.text = self.user.favourites[indexPath.row].outlet.name
            if (self.user.favourites[indexPath.row].outlet.offers[0].type != nil) {cell.voucherOfferType.text =  self.user.favourites[indexPath.row].outlet.offers[0].type.name} else {cell.voucherOfferType.text = ""}
            if distance >= 1 {cell.voucherLocation.text = self.user.favourites[indexPath.row].outlet.city + " " + String(Int(distance.rounded(.toNearestOrEven))) + "km"} else {cell.voucherLocation.text = self.user.favourites[indexPath.row].outlet.city + " " + String(Int(distanceMeters.rounded(.toNearestOrEven))) + "m"}
            var offersavings: Double = 0
            for offer in self.user.favourites[indexPath.row].outlet.offers {
                offersavings += Double(offer.max_savings)! * Double(offer.quantity)
            }
            cell.voucherEstimatedSavings.text = "ESTIMATED SAVINGS €" + String(offersavings)
        }
        
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //: Load User
        let defaults = UserDefaults.standard
        if let savedUser = defaults.object(forKey: "SavedUser") as? Data {
            do {
                user = try User.decode(data: savedUser)
            } catch {
                print("Error decoding user data from defaults")
            }
        }
        
        //: Calculate total possible savings
        var totalSavings: Double = 0
        for userFavourite: UserFavourite in user.favourites {
            for offer: Offer in userFavourite.outlet.offers {
                totalSavings += Double(offer.max_savings)! * Double(offer.quantity)
            }
        }
        totalSavingsLabel.text = "TOTAL SAVINGS: €" + String(Int(totalSavings.rounded(.up)))
        
        self.outletsTableView.delegate = self
        self.outletsTableView.dataSource = self
        self.locationManager.delegate = self
        
        //: Handle location
        locationManager.startUpdatingLocation()
        locationManager.distanceFilter = 100
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
                voucherDetailsViewController.outlet = user.favourites[selectedRow].outlet
                voucherDetailsViewController.currentLocation = currentLocation
                voucherDetailsViewController.previousVC = "favourites"
            }
        }
    }
    
    @IBAction func unwindToFavouritesViewController(_ segue: UIStoryboardSegue) {
        let defaults = UserDefaults.standard
        if let savedUser = defaults.object(forKey: "SavedUser") as? Data {
            do {
                user = try User.decode(data: savedUser)
            } catch {
                print("Error decoding user data from defaults")
            }
        }
        outletsTableView.reloadData()
        //: Calculate total possible savings
        var totalSavings: Double = 0
        for userFavourite: UserFavourite in user.favourites {
            for offer: Offer in userFavourite.outlet.offers {
                totalSavings += Double(offer.max_savings)! * Double(offer.quantity)
            }
        }
        totalSavingsLabel.text = "TOTAL SAVINGS: €" + String(Int(totalSavings.rounded(.up)))
    }
    
}

//
//  VoucherDetailsViewController.swift
//  Access Algarve Light
//
//  Created by Daniel Santos on 06/03/2018.
//  Copyright © 2018 Daniel Santos. All rights reserved.
//

import UIKit
import CoreLocation

class OutletDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    @IBOutlet weak var merchantImage: UIImageView!
    @IBOutlet weak var merchantName: UILabel!
    @IBOutlet weak var merchantDescription: UILabel!
    @IBOutlet weak var outletCity: UILabel!
    @IBOutlet weak var outletPhone: UIButton!
    @IBOutlet weak var outletFacebook: UIButton!
    @IBOutlet weak var outletWebsite: UIButton!
    @IBOutlet weak var outletGPS: UIButton!
    
    @IBOutlet weak var favoutiteButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var iconsView: UIView!
    @IBOutlet weak var vouchersTableView: UITableView!
    
    var outlet: Outlet!
    var outletOffers: [Offer] = []
    var user: User!
    var hasValidSubscription: Bool = false
    
    let locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocation!
    var previousVC: String!
    
    //: Define Colors
    let pink = UIColor(red: 221.0/255.0, green: 78.0/255.0, blue: 149.0/255.0, alpha: 1.0)
    let orange = UIColor(red: 235.0/255.0, green: 128.0/255.0, blue: 0.0/255.0, alpha: 1.0)
    let blue = UIColor(red: 64.0/255.0, green: 191.0/255.0, blue: 239.0/255.0, alpha: 1.0)
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return outletOffers.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "voucherCell", for: indexPath) as! ViewControllerTableViewCell
        
        var unlockedCell = false
        if self.outletOffers[indexPath.row].quantity > 0 {unlockedCell = true}
        
        if self.hasValidSubscription && unlockedCell {
            switch self.outletOffers[indexPath.row].offer_category_id {
            case 1:
                cell.voucherOfferName.textColor = self.pink
                cell.voucherOfferType.textColor = self.pink
                cell.voucherArrow.setImage(UIImage(named: "pink-arrow"), for: .normal)
            case 3:
                cell.voucherOfferName.textColor = self.orange
                cell.voucherOfferType.textColor = self.orange
                cell.voucherArrow.setImage(UIImage(named: "orange-arrow"), for: .normal)
            default:
                cell.voucherOfferName.textColor = self.blue
                cell.voucherOfferType.textColor = self.blue
                cell.voucherArrow.setImage(UIImage(named: "blue-arrow"), for: .normal)
            }
            cell.voucherLock.isHidden = true
        }
        
        //: Handle distance
        /*
        let coordstring = self.outlet.gps.replacingOccurrences(of: " ", with: "")
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
        if distance >= 1 {cell.voucherLocation.text = self.outlet.city + " " + String(Int(distance.rounded(.toNearestOrEven))) + "km"} else {cell.voucherLocation.text = self.outlet.city + " " + String(Int(distanceMeters.rounded(.toNearestOrEven))) + "m"}
        */
        
        if (self.outlet.merchant != nil) {cell.voucherCompanyLogo.downloadedFrom(link: "https://www.accessalgarve.com/images/logos/\(self.outlet.merchant.id)-logo.png")}
        if (self.outletOffers[indexPath.row].offer_heading != nil) {cell.voucherOfferName.text = self.outletOffers[indexPath.row].offer_heading}  else {cell.voucherOfferName.text = ""}
        if (self.outletOffers[indexPath.row].offer_type != nil) {cell.voucherOfferType.text = self.outletOffers[indexPath.row].name} else {cell.voucherOfferType.text = ""}
        var offersavings: Double = 0
        offersavings = Double(self.outletOffers[indexPath.row].max_savings)!
        cell.voucherEstimatedSavings.text = "ESTIMATED SAVINGS €" + String(offersavings)
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.hasValidSubscription && outletOffers[indexPath.row].quantity > 0 {self.performSegue(withIdentifier: "redeemOfferSegue", sender: self)} else {self.performSegue(withIdentifier: "blockedOfferSegue", sender: self)}
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
        
        //: Cache validSubscription
        hasValidSubscription = hasValidSubscription(forUser: user)
        var numberOfValidSubscriptions = countValidSubscription(forUser: user)
        if numberOfValidSubscriptions == 0 {numberOfValidSubscriptions = 1} //Otherwise free user cannot browse offers
        
        //: Create the offers array based on quantity
        for offer in outlet.offers {
            var currentOffer: Offer!
            var coms: Double = 0
            coms = Double(offer.max_savings)!
            currentOffer = offer
            currentOffer.max_savings = String((coms / Double(offer.quantity)).rounded())
            currentOffer.quantity = 1
            outletOffers.append(contentsOf: Array(repeatElement(currentOffer, count: offer.quantity * numberOfValidSubscriptions)))
        }
        
        //: Lock already used vouchers
        for redemption in user.redemptions {
            for (index, offer) in outletOffers.enumerated() {
                if redemption.offer_id == offer.id && offer.quantity > 0 {
                    outletOffers[index].quantity = 0
                    break
                }
            }
        }
        
        //: Turn heart on if outlet belongs to user favourites
        if user.favourites != nil {for userFavourite: UserFavourite in user.favourites {
            if userFavourite.outlet_id == outlet.id {favoutiteButton.setImage(UIImage(named: "favourites-heart-icon-selected"), for: .normal)}
            }}
        
        self.vouchersTableView.delegate = self
        self.vouchersTableView.dataSource = self
        self.locationManager.delegate = self
        
        //: Handle location
        locationManager.startUpdatingLocation()
        locationManager.distanceFilter = 100
        
        //: Handle distance
        let coordstring = outlet.gps.replacingOccurrences(of: " ", with: "")
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
        
        //: Change button collours depending on button pressed
        switch Int(outlet.offers[0].offer_category_id) {
        case 1:
            backButton.setImage(UIImage(named: "back-arrow-pink"), for: .normal)
            iconsView.backgroundColor = pink
            outletPhone.setImage(UIImage(named: "phone-pink"), for: .normal)
            outletFacebook.setImage(UIImage(named: "facebook-pink"), for: .normal)
            outletWebsite.setImage(UIImage(named: "web-pink"), for: .normal)
            outletGPS.setImage(UIImage(named: "adress-pink"), for: .normal)
        case 3:
            backButton.setImage(UIImage(named: "back-arrow-orange"), for: .normal)
            iconsView.backgroundColor = orange
            outletPhone.setImage(UIImage(named: "phone-orange"), for: .normal)
            outletFacebook.setImage(UIImage(named: "facebook-orange"), for: .normal)
            outletWebsite.setImage(UIImage(named: "web-orange"), for: .normal)
            outletGPS.setImage(UIImage(named: "adress-orange"), for: .normal)
        default:
            backButton.setImage(UIImage(named: "back-arrow-blue"), for: .normal)
            iconsView.backgroundColor = blue
            outletPhone.setImage(UIImage(named: "phone-blue"), for: .normal)
            outletFacebook.setImage(UIImage(named: "facebook-blue"), for: .normal)
            outletWebsite.setImage(UIImage(named: "web-blue"), for: .normal)
            outletGPS.setImage(UIImage(named: "adress-blue"), for: .normal)
        }
        
        let tableHeight = Double(outletOffers.count * 111)
        self.vouchersTableView.heightAnchor.constraint(equalToConstant: CGFloat(tableHeight)).isActive = true
        self.vouchersTableView.translatesAutoresizingMaskIntoConstraints = true
        
        let imageLink = "https://www.accessalgarve.com/images/logos/\(outlet.merchant.id)-image.jpg"
        merchantImage.downloadedFrom(link: imageLink)
        merchantImage.contentMode = UIViewContentMode.scaleAspectFill;
        merchantImage.layer.masksToBounds = true;
        merchantName.text = outlet.name
        merchantDescription.text = outlet.merchant.description
        if distance >= 1 {outletCity.text = outlet.city + " " + String(Int(distance.rounded(.toNearestOrEven))) + "km"} else {outletCity.text = outlet.city + " " + String(Int(distanceMeters.rounded(.toNearestOrEven))) + "m"}
        
        //: Hide unnecessary buttons
        if outlet.phone == "" {outletPhone.removeFromSuperview()}
        if outlet.facebook == "" {outletFacebook.removeFromSuperview()}
        if outlet.website == "" {outletWebsite.removeFromSuperview()}
        if outlet.gps == "" {outletGPS.removeFromSuperview()}
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            currentLocation = location
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "redeemOfferSegue" {
            if let indexPath = vouchersTableView.indexPathForSelectedRow {
                let selectedRow = indexPath.row
                guard let redeemViewController = segue.destination as? RedeemViewController else {return}
                redeemViewController.outlet = outlet
                redeemViewController.offer = outletOffers[selectedRow]
            }
        } else if segue.identifier == "blockedOfferSegue" {
            if let indexPath = vouchersTableView.indexPathForSelectedRow {
                let selectedRow = indexPath.row
                guard let blockedOfferViewController = segue.destination as? BlockedOfferViewController else {return}
                blockedOfferViewController.outlet = outlet
                blockedOfferViewController.offer = outletOffers[selectedRow]
            }
        } else if segue.identifier == "showFavourites" {
            guard let favouritesViewController = segue.destination as? FavouritesViewController else {return}
            favouritesViewController.currentLocation = currentLocation
        } else if segue.identifier == "viewOutletLocationSegue" {
            guard let outletLocationNavigationViewController = segue.destination as? UINavigationController else {return}
            guard let outletLocationViewController = outletLocationNavigationViewController.topViewController as? OutletLocationViewController else {return}
            outletLocationViewController.outlet = outlet
        }
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        switch previousVC {
        case "main":
            self.performSegue(withIdentifier: "didUnwindFromOutletSegue", sender: self)
        case "favourites":
            self.performSegue(withIdentifier: "didUnwindToFavouritesSegue", sender: self)
        case "searchresults":
            self.performSegue(withIdentifier: "didUnwindToSearchResultsSegue", sender: self)
        default:
            self.performSegue(withIdentifier: "didUnwindFromOutletDetailsSegue", sender: self)
        }
    }
    
    @IBAction func callButton(sender: AnyObject) {
        if let url = URL(string: "tel://+" + outlet.phone.replacingOccurrences(of: " ", with: "")) {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    @IBAction func facebookButton(_ sender: Any) {
        if let url = URL(string: outlet.facebook) {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    @IBAction func websiteButton(_ sender: Any) {
        if let url = URL(string: outlet.website) {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    @IBAction func favouriteButtonClicked(_ sender: Any) {
        if favoutiteButton.image(for: .normal) == UIImage(named: "favourites-heart-icon-unselected") {favoutiteButton.setImage(UIImage(named: "favourites-heart-icon-selected"), for: .normal)} else {favoutiteButton.setImage(UIImage(named: "favourites-heart-icon-unselected"), for: .normal)}
        let parameters = ["user_id": user.id, "outlet_id": outlet.id]
        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(parameters)
            self.postAPIResults(endpoint: "users/togglefavourite", parameters: jsonData) { userData in
                do {
                    //: Save API call returned user to self
                    self.user = try User.decode(data: userData)
                    //: Encode self user and save in defaults
                    let defaults = UserDefaults.standard
                    let encodedUser = try self.user.encode()
                    defaults.set(encodedUser, forKey: "SavedUser")
                } catch {
                    print("Error encoding user data to defaults")
                }
            }
        } catch {
            print(error)
        }
    }
    
    @IBAction func didUnwindFromRedeemController(_ segue: UIStoryboardSegue) {
        
    }
    
}

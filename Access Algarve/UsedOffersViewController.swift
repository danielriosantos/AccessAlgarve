//
//  UsedOffersViewController.swift
//  Access Algarve
//
//  Created by Daniel Santos on 27/03/2018.
//  Copyright © 2018 Daniel Santos. All rights reserved.
//

import UIKit

class UsedOffersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var user: User!
    var currentColor: UIColor!
    @IBOutlet weak var outletsTableView: UITableView!
    
    //: Define Colors
    let pink = UIColor(red: 221.0/255.0, green: 78.0/255.0, blue: 149.0/255.0, alpha: 1.0)
    let orange = UIColor(red: 235.0/255.0, green: 128.0/255.0, blue: 0.0/255.0, alpha: 1.0)
    let blue = UIColor(red: 64.0/255.0, green: 191.0/255.0, blue: 239.0/255.0, alpha: 1.0)
    let white = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0)
    let invisible = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0)
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return user.redemptions.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // set up cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "voucherCell", for: indexPath) as! ViewControllerTableViewCell
        DispatchQueue.main.async() {
            switch self.user.redemptions[indexPath.row].offer.offer_category_id {
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
            
            if (self.user.redemptions[indexPath.row].offer.outlet.merchant != nil) {cell.voucherCompanyLogo.downloadedFrom(link: "https://www.accessalgarve.com/images/logos/\(self.user.redemptions[indexPath.row].offer.outlet.merchant.id)-logo.png")}
            cell.voucherOfferName.text = self.user.redemptions[indexPath.row].offer.outlet.name
            if (self.user.redemptions[indexPath.row].offer.type != nil) {cell.voucherOfferType.text =  self.user.redemptions[indexPath.row].offer.type.name} else {cell.voucherOfferType.text = ""}
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let redeemDate = formatter.date(from: self.user.redemptions[indexPath.row].created_at)
            formatter.dateFormat = "dd/MM/yyyy"
            let redeemDateString = formatter.string(from: redeemDate!)
            
            cell.voucherLocation.text = "Redeemed on " + redeemDateString
            cell.voucherEstimatedSavings.text = "SAVED €" + String((Double(self.user.redemptions[indexPath.row].offer.max_savings)!/Double(self.user.redemptions[indexPath.row].offer.quantity)))
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
        
        self.outletsTableView.delegate = self
        self.outletsTableView.dataSource = self
        
    }

}

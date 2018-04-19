//
//  PurchaseHistoryViewController.swift
//  Access Algarve
//
//  Created by Daniel Santos on 27/03/2018.
//  Copyright © 2018 Daniel Santos. All rights reserved.
//

import UIKit

class PurchaseHistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var user: User!
    var currentColor: UIColor!
    @IBOutlet weak var purchasesTableView: UITableView!
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return user.subscriptions.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // set up cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "purchaseCell", for: indexPath) as! PurchaseHistoryTableViewCell
        DispatchQueue.main.async() {
            cell.productName.text = self.user.subscriptions[indexPath.row].product.name
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            formatter.locale = Locale(identifier: "UTC")
            let expiryDate = formatter.date(from: self.user.subscriptions[indexPath.row].end_date)
            formatter.dateFormat = "dd MMM yyyy"
            let expiryDateString = formatter.string(from: expiryDate!)
            cell.productExpiry.text = "All vouchers are valid until " + expiryDateString
            
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            formatter.locale = Locale(identifier: "UTC")
            let purchaseDate = formatter.date(from: self.user.subscriptions[indexPath.row].created_at)
            formatter.dateFormat = "dd/MM/yyyy"
            let purchaseDateString = formatter.string(from: purchaseDate!)
            cell.purchaseDate.text = "Purchase Date: " + purchaseDateString
            
            cell.productPrice.text = String(Int((Double(self.user.subscriptions[indexPath.row].product.price)?.rounded(.up))!)) + "€"
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
        
        self.purchasesTableView.delegate = self
        self.purchasesTableView.dataSource = self
    }

}

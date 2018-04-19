//
//  CartViewController.swift
//  Access Algarve Light
//
//  Created by Daniel Santos on 22/03/2018.
//  Copyright © 2018 Daniel Santos. All rights reserved.
//

import UIKit
import CoreLocation
import SVProgressHUD

class CartViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {

    @IBOutlet weak var productsTableView: UITableView!
    var products = [Product]()
    var selectedProduct: Product!
    
    let locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // set up cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "cartCell", for: indexPath) as! CartTableViewCell
        DispatchQueue.main.async() {
            cell.productImage.downloadedFrom(link: "https://admin.accessalgarve.com/images/products/product-\(self.products[indexPath.row].id).png")
            cell.productName.text = self.products[indexPath.row].name
        }
        
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.productsTableView.delegate = self
        self.productsTableView.dataSource = self
        self.locationManager.delegate = self
        
        //: Handle location
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.distanceFilter = 100
        
        //: Initiate loader
        DispatchQueue.main.async {SVProgressHUD.show(withStatus: "Loading")}
        
        //: Get the products
        getAPIResults(endpoint: "products", parameters: nil) {productsData in
            do {
                self.products = try [Product].decode(data: productsData)
                DispatchQueue.main.async {
                    self.productsTableView.reloadData()
                    SVProgressHUD.dismiss()
                }
            } catch {
                print("Error getting products from API")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            currentLocation = location
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueidentifier = segue.identifier else {return}
        if segueidentifier == "viewProductDetailsSegue" {
            //let cartDetailsViewController = CartDetailsViewController(product: self.selectedProduct)
            //self.navigationController?.pushViewController(cartDetailsViewController, animated: true)
            guard let cartDetailsViewController = segue.destination as? CartDetailsViewController else {return}
            cartDetailsViewController.product = self.selectedProduct
        } else if segueidentifier == "showFavourites" {
            guard let favouritesViewController = segue.destination as? FavouritesViewController else {return}
            favouritesViewController.currentLocation = currentLocation
        }
    }
    
    @IBAction func purchaseButtonClicked(_ sender: UIButton) {
        guard let cell = sender.superview?.superview as? CartTableViewCell else {return}
        if let indexPath = productsTableView?.indexPath(for: cell) {
            let selectedRow = indexPath.row
            self.selectedProduct = products[selectedRow]
            self.performSegue(withIdentifier: "viewProductDetailsSegue", sender: self)
        }
    }
    
    @IBAction func unwindToCartViewController(_ segue: UIStoryboardSegue) {
        
    }

}

//
//  CartDetailsViewController.swift
//  Access Algarve
//
//  Created by Daniel Santos on 31/03/2018.
//  Copyright © 2018 Daniel Santos. All rights reserved.
//

import UIKit
import CoreLocation
import SVProgressHUD
import SwiftyXMLParser

class CartDetailsViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {

    var product: Product!
    var subscription: Subscription!
    
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productExpiry: UILabel!
    @IBOutlet weak var cartTotal: UILabel!
    @IBOutlet weak var promoCode: UITextField!
    
    let locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.promoCode.delegate = self
        self.locationManager.delegate = self
        
        //: Handle location
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.distanceFilter = 100
        
        productImage.downloadedFrom(link: "https://admin.accessalgarve.com/images/products/product-\(self.product.id).png")
        productName.text = product.name
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let expiryDate = formatter.date(from: self.product.end_date)
        formatter.dateFormat = "dd MMM yyyy"
        let expiryDateString = formatter.string(from: expiryDate!)
        productExpiry.text = "All vouchers are valid until " + expiryDateString
        cartTotal.text = "Total: " + String(Int((Double(self.product.price)?.rounded(.up))!)) + "€"
        
        //print(product)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            currentLocation = location
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueidentifier = segue.identifier else {return}
        if segueidentifier == "goHome" {
            guard let viewController = segue.destination as? ViewController else {return}
            viewController.currentLocation = self.currentLocation
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        checkCode() {_ in}
        return true
    }
    
    func checkCode(callback: @escaping (Coupon?)->() ) {
        DispatchQueue.main.async {SVProgressHUD.show(withStatus: "Loading")}
        let params = ["code": self.promoCode.text!]
        getAPIResults(endpoint: "coupons/validate", parameters: params) {couponData in
            do {
                //print(String(data: couponData, encoding: .utf8)!)
                let discount: Coupon = try Coupon.decode(data: couponData)
                var price: Double = Double(self.product.price)!
                if discount.discount_percentage != nil {
                    price = Double(self.product.price)! * (1.0 - Double(discount.discount_percentage) / 100.0)
                } else if discount.discount_value != nil && discount.discount_value != "" {
                    price = Double(self.product.price)! - Double(discount.discount_value)!
                }
                DispatchQueue.main.async {
                    self.cartTotal.text = "Total: " + String(Int(price.rounded(.up))) + "€"
                    self.product.price = String(price)
                    SVProgressHUD.dismiss()
                }
                callback(discount)
            } catch {
                DispatchQueue.main.async {SVProgressHUD.dismiss()}
                callback(nil)
                print("Error - Discount is invalid")
            }
        }
    }


    @IBAction func purchaseButtonClicked(_ sender: UIButton) {
        checkCode() {coupon in
            var params = ["user_id": 2, "product_id": self.product.id, "start_date": self.product.start_date, "end_date": self.product.end_date ] as [String : Any]
            var requestPayment = true
            if Double(self.product.price) == 0 {
                params["status"] = 1
                requestPayment = false
            } else {
                params["status"] = 0
            }
            if coupon != nil {params["coupon_id"] = coupon?.id}
            DispatchQueue.main.async {SVProgressHUD.show(withStatus: "Loading")}
            self.postAPIResults(endpoint: "subscriptions", parameters: params) {subscriptionData in
                //print(String(data: subscriptionData, encoding: .utf8)!)
                do {
                    self.subscription = try Subscription.decode(data: subscriptionData)
                    if requestPayment {
                        let params = [
                            "ep_cin": 7061,
                            "ep_user": "SANDCH230318",
                            "ep_entity": 10611,
                            "ep_ref_type": "auto",
                            "ep_country": "PT",
                            "ep_language": "GB",
                            "t_value": self.product.price,
                            "t_key": self.subscription.id,
                            "o_name": "User Name",
                            "o_description ": self.product.name,
                            "o_obs": "",
                            "o_mobile": "",
                            "o_email": "user@email.com",
                            "s_code": "79ec4f6125fde31117823e155a4858ba"
                            ] as [String : Any]
                        self.getEasyPayPaymentIdentifier(parameters: params) {response in
                            //let utf8Representation = String(data: response, encoding: .utf8)
                            //print("response: ", utf8Representation!)
                            let xml = XML.parse(response)
                            let link = xml["getautoMB"]["ep_link"].text! + "&s_code=79ec4f6125fde31117823e155a4858ba"
                            print(link)
                            let url = URL(string: link)
                            DispatchQueue.main.async {
                                SVProgressHUD.dismiss()
                                self.performSegue(withIdentifier: "goHome", sender: self)
                                UIApplication.shared.open(url!, options: [:])
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            SVProgressHUD.dismiss()
                            self.performSegue(withIdentifier: "goHome", sender: self)
                        }
                    }
                } catch {
                    DispatchQueue.main.async {SVProgressHUD.dismiss()}
                    print("Error decoding subscription results")
                }
            }
        }
    }
    
}

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
import Stripe

class CartDetailsViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate, STPPaymentContextDelegate {

    var product: Product!
    var requestParams: [String: Any]!
    var subscription: Subscription!
    var user: User!
    
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productExpiry: UILabel!
    @IBOutlet weak var cartTotal: UILabel!
    @IBOutlet weak var promoCode: UITextField!
    @IBOutlet weak var buyButton: UIButton!
    
    let locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    //: Define Stripe Variables
    let backendBaseURL: String? = "https://admin.accessalgarve.com/api/subscriptions/"
    let paymentCurrency = "eur"
    let paymentContext: STPPaymentContext
    let theme: STPTheme
    let paymentRow: CheckoutRowView
    let rowHeight: CGFloat = 44
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    let numberFormatter: NumberFormatter
    var paymentInProgress: Bool = false {
        didSet {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                if self.paymentInProgress {
                    DispatchQueue.main.async {
                        self.activityIndicator.startAnimating()
                        self.activityIndicator.alpha = 1
                        self.buyButton.alpha = 0
                    }
                }
                else {
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.alpha = 0
                        self.buyButton.alpha = 1
                    }
                }
            }, completion: nil)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    required init?(coder aDecoder: NSCoder) {
        
        //: Load user from defaults
        let defaults = UserDefaults.standard
        if let savedUser = defaults.object(forKey: "SavedUser") as? Data {
            do {
                self.user = try User.decode(data: savedUser)
            } catch {
                print("Error decoding user data from defaults")
            }
        }
        
        let backendBaseURL = self.backendBaseURL
        assert(backendBaseURL != nil, "You must set your backend base url at the top of CheckoutViewController.swift to run this app.")
        
        self.theme = STPTheme.default()
        MyAPIClient.sharedClient.baseURLString = self.backendBaseURL
        MyAPIClient.sharedClient.user = self.user
        
        let customerContext = STPCustomerContext(keyProvider: MyAPIClient.sharedClient)
        let paymentContext = STPPaymentContext(customerContext: customerContext, configuration: STPPaymentConfiguration.shared(), theme: self.theme)
        let userInformation = STPUserInformation()
        paymentContext.prefilledInformation = userInformation
        //paymentContext.paymentAmount = Int(self.product.price)! * 100
        paymentContext.paymentCurrency = self.paymentCurrency
        
        let paymentSelectionFooter = PaymentContextFooterView(text: "Please Enter Your Card Information Here")
        paymentSelectionFooter.theme = .default()
        paymentContext.paymentMethodsViewControllerFooterView = paymentSelectionFooter
        
        self.paymentContext = paymentContext
        
        self.paymentRow = CheckoutRowView(title: "Payment Method", detail: "Select", theme: self.theme)
        
        var localeComponents: [String: String] = [
            NSLocale.Key.currencyCode.rawValue: self.paymentCurrency,
            ]
        localeComponents[NSLocale.Key.languageCode.rawValue] = NSLocale.preferredLanguages.first
        let localeID = NSLocale.localeIdentifier(fromComponents: localeComponents)
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale(identifier: localeID)
        numberFormatter.numberStyle = .currency
        numberFormatter.usesGroupingSeparator = true
        self.numberFormatter = numberFormatter
        
        //super.init(nibName: nil, bundle: nil)
        super.init(coder: aDecoder)
        self.paymentContext.delegate = self
        paymentContext.hostViewController = self
    }
    
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
        formatter.locale = Locale(identifier: "UTC")
        let expiryDate = formatter.date(from: self.product.end_date)
        formatter.dateFormat = "dd MMM yyyy"
        let expiryDateString = formatter.string(from: expiryDate!)
        productExpiry.text = "All vouchers are valid until " + expiryDateString
        cartTotal.text = "Total: " + String(Int((Double(self.product.price)?.rounded(.up))!)) + "€"
        
        //print(product)
        
        self.paymentContext.paymentAmount = Int((Double(self.product.price)?.rounded(.up))!) * 100
        self.view.addSubview(self.paymentRow)
        self.view.addSubview(self.activityIndicator)
        self.activityIndicator.alpha = 0
        //self.buyButton.addTarget(self, action: #selector(didTapBuy), for: .touchUpInside)
        self.paymentRow.onTap = { [weak self] in
            print("Amount: " + String((self?.paymentContext.paymentAmount)!/100))
            self?.paymentContext.presentPaymentMethodsViewController()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var insets = UIEdgeInsets.zero
        if #available(iOS 11.0, *) {
            insets = view.safeAreaInsets
        }
        let width = self.view.bounds.width - (insets.left + insets.right)
        self.paymentRow.frame = CGRect(x: insets.left, y: self.buyButton.frame.maxY + 20, width: width, height: rowHeight)
        self.activityIndicator.center = self.buyButton.center
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        let alertController = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            // Need to assign to _ because optional binding loses @discardableResult value
            // https://bugs.swift.org/browse/SR-1681
            _ = self.navigationController?.popViewController(animated: true)
        })
        let retry = UIAlertAction(title: "Retry", style: .default, handler: { action in
            self.paymentContext.retryLoading()
        })
        alertController.addAction(cancel)
        alertController.addAction(retry)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        self.paymentRow.loading = paymentContext.loading
        if let paymentMethod = paymentContext.selectedPaymentMethod {
            self.paymentRow.detail = paymentMethod.label
        }
        else {
            self.paymentRow.detail = "Select"
        }
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPErrorBlock) {
        MyAPIClient.sharedClient.completeCharge(paymentResult, amount: self.paymentContext.paymentAmount, requestparams: self.requestParams, completion: completion)
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        self.paymentInProgress = false
        let title: String
        let message: String
        let action: UIAlertAction
        switch status {
        case .error:
            title = "Error"
            //message = error?.localizedDescription ?? ""
            message = "Your Card was not accepted. Please use a different card and try again!"
            action = UIAlertAction(title: "OK", style: .default, handler: nil)
        case .success:
            title = "Success"
            message = "You bought a \(self.product.name)!"
            action = UIAlertAction(title: "OK", style: .default) {UIAlertAction in
                self.performSegue(withIdentifier: "goHome", sender: self)
            }
        case .userCancellation:
            return
        }
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
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
                self.product.price = String(price)
                DispatchQueue.main.async {
                    self.cartTotal.text = "Total: " + String(Int(price.rounded(.up))) + "€"
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
            var params = ["user_id": self.user.id, "product_id": self.product.id, "start_date": self.product.start_date, "end_date": self.product.end_date, "status": 1 ] as [String : Any]
            var requestPayment = true
            if Double(self.product.price) == 0 {
                requestPayment = false
            }
            if coupon != nil {params["coupon_id"] = coupon?.id}

            if requestPayment {
                self.requestParams = params
                self.paymentInProgress = true
                self.paymentContext.requestPayment()
            } else {
                DispatchQueue.main.async {SVProgressHUD.show(withStatus: "Processing Subscription")}
                self.postAPIResults(endpoint: "subscriptions", parameters: params) {subscriptionData in
                    //print(String(data: subscriptionData, encoding: .utf8)!)
                    do {
                        self.subscription = try Subscription.decode(data: subscriptionData)
                        DispatchQueue.main.async {
                            SVProgressHUD.dismiss()
                            self.performSegue(withIdentifier: "goHome", sender: self)
                        }
                    } catch {
                        DispatchQueue.main.async {SVProgressHUD.dismiss()}
                        print("Error decoding subscription results")
                    }
                }
            }
            
        }
    }
    
}

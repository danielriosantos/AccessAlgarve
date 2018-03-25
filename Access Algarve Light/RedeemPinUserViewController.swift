//
//  RedeemPinUserViewController.swift
//  Access Algarve Light
//
//  Created by Daniel Santos on 13/03/2018.
//  Copyright © 2018 Daniel Santos. All rights reserved.
//

import UIKit

class RedeemPinUserViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var voucherBackground: UIImageView!
    @IBOutlet weak var enterPinMessage: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var pin1: UITextField!
    @IBOutlet weak var pin2: UITextField!
    @IBOutlet weak var pin3: UITextField!
    @IBOutlet weak var pin4: UITextField!
    
    @IBOutlet weak var merchantLogo: UIImageView!
    @IBOutlet weak var merchantName: UILabel!
    @IBOutlet weak var offerName: UILabel!
    @IBOutlet weak var validUntil: UILabel!
    
    var outlet: Outlet!
    var offer: Offer!
    var user: User!
    
    //: Define Colors
    let pink = UIColor(red: 221.0/255.0, green: 78.0/255.0, blue: 149.0/255.0, alpha: 1.0)
    let orange = UIColor(red: 235.0/255.0, green: 128.0/255.0, blue: 0.0/255.0, alpha: 1.0)
    let blue = UIColor(red: 64.0/255.0, green: 191.0/255.0, blue: 239.0/255.0, alpha: 1.0)
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return textField.shouldChangeCustomOtp(textField: textField, string: string)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //: Set Colors
        var currentColor: UIColor
        var currentColorName: String
        switch offer.offer_category_id {
        case 1:
            currentColor = pink
            currentColorName = "pink"
        case 3:
            currentColor = orange
            currentColorName = "orange"
        default:
            currentColor = blue
            currentColorName = "blue"
        }
        voucherBackground.image = UIImage(named: "small-voucher-box-" + currentColorName)
        enterPinMessage.textColor = currentColor
        merchantName.textColor = currentColor
        offerName.textColor = currentColor
        nextButton.setImage(UIImage(named: "next-button-" + currentColorName), for: .normal)
        
        pin1.delegate = self
        pin2.delegate = self
        pin3.delegate = self
        pin4.delegate = self

        let imageLink = "https://www.accessalgarve.com/images/logos/\(outlet.merchant.id)-logo.png"
        merchantLogo.downloadedFrom(link: imageLink)
        merchantLogo.contentMode = UIViewContentMode.scaleAspectFit
        merchantLogo.layer.masksToBounds = true
        merchantName.text = outlet.merchant.name
        offerName.text = offer.name
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let validDate = formatter.date(from: offer.end_date)
        formatter.dateFormat = "dd MMM yyyy"
        let validDateString = formatter.string(from: validDate!)
        validUntil.text = "Valid Until " + validDateString
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "correctUserPinSegue" {
            guard let redeemPinOutletViewController = segue.destination as? RedeemPinOutletViewController else {return}
            redeemPinOutletViewController.outlet = outlet
            redeemPinOutletViewController.offer = offer
        }
    }
    
    @IBAction func checkUserPin(_ sender: UIButton) {
        //: Read user pin from UserDefaults
        let defaults = UserDefaults.standard
        if let savedUser = defaults.object(forKey: "SavedUser") as? Data {
            do {
                user = try User.decode(data: savedUser)
                let enteredPIN = pin1.text! + pin2.text! + pin3.text! + pin4.text!
                if user.pin != nil {
                    if enteredPIN.count == 4 && enteredPIN == user.pin {
                        self.performSegue(withIdentifier: "correctUserPinSegue", sender: self)
                    } else {
                        let alert = UIAlertController(title: "Error", message: "The PIN is incorrect", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                } else {
                    let alert = UIAlertController(title: "Error", message: "Your PIN is not set. Please go to your profile and set your PIN first", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            } catch {
                print("Error decoding user data from defaults")
            }
        }
    }

}

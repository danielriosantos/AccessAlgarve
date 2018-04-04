//
//  RedeemViewController.swift
//  Access Algarve Light
//
//  Created by Daniel Santos on 13/03/2018.
//  Copyright © 2018 Daniel Santos. All rights reserved.
//

import UIKit
import QuartzCore

class RedeemViewController: UIViewController {

    @IBOutlet weak var voucherBackground: UIView!
    @IBOutlet weak var merchantLogo: UIImageView!
    @IBOutlet weak var merchantName: UILabel!
    @IBOutlet weak var offerName: UILabel!
    @IBOutlet weak var savings: UILabel!
    @IBOutlet weak var offerConditions: UILabel!
    @IBOutlet weak var calendarIcon: UIImageView!
    @IBOutlet weak var validUntil: UILabel!
    @IBOutlet weak var redeemButton: UIButton!
    
    var outlet: Outlet!
    var offer: Offer!
    
    //: Define Colors
    let pink = UIColor(red: 221.0/255.0, green: 78.0/255.0, blue: 149.0/255.0, alpha: 1.0)
    let orange = UIColor(red: 235.0/255.0, green: 128.0/255.0, blue: 0.0/255.0, alpha: 1.0)
    let blue = UIColor(red: 64.0/255.0, green: 191.0/255.0, blue: 239.0/255.0, alpha: 1.0)
    
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
        voucherBackground.backgroundColor = currentColor
        merchantName.textColor = currentColor
        offerName.textColor = currentColor
        offerConditions.textColor = currentColor
        calendarIcon.image = UIImage(named: currentColorName + "-calendar-icon")
        redeemButton.setImage(UIImage(named: currentColorName + "-redeem-button"), for: .normal)
        
        var imageLink = ""
        if outlet.id == 128 || outlet.id == 140 {
            imageLink = "https://admin.accessalgarve.com/images/barcodes/\(offer.id)-barcode.png"
        } else {
            imageLink = "https://www.accessalgarve.com/images/logos/\(outlet.merchant.id)-logo.png"
        }
        merchantLogo.downloadedFrom(link: imageLink)
        merchantLogo.contentMode = UIViewContentMode.scaleAspectFit
        merchantLogo.layer.masksToBounds = true
        merchantName.text = outlet.merchant.name
        offerName.text = offer.name
        savings.text = "Savings: €" + offer.max_savings
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let validDate = formatter.date(from: offer.end_date)
        formatter.dateFormat = "dd MMM yyyy"
        let validDateString = formatter.string(from: validDate!)
        validUntil.text = "Valid Until " + validDateString
        if offer.description != "" {offerConditions.text = offer.description} else {offerConditions.text = ""}
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "redeemOfferSegue2" {
//            guard let redeemPinUserViewController = segue.destination as? RedeemPinUserViewController else {return}
//            redeemPinUserViewController.outlet = outlet
//            redeemPinUserViewController.offer = offer
            guard let redeemPinOutletViewController = segue.destination as? RedeemPinOutletViewController else {return}
            redeemPinOutletViewController.outlet = outlet
            redeemPinOutletViewController.offer = offer
        }
    }
    
    

}

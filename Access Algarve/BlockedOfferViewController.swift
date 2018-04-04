//
//  BlockedOfferViewController.swift
//  Access Algarve
//
//  Created by Daniel Santos on 28/03/2018.
//  Copyright © 2018 Daniel Santos. All rights reserved.
//

import UIKit

class BlockedOfferViewController: UIViewController {

    @IBOutlet weak var merchantLogo: UIImageView!
    @IBOutlet weak var merchantName: UILabel!
    @IBOutlet weak var offerName: UILabel!
    @IBOutlet weak var offerSavings: UILabel!
    @IBOutlet weak var offerExpiry: UILabel!
    
    var outlet: Outlet!
    var offer: Offer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageLink = "https://www.accessalgarve.com/images/logos/\(outlet.merchant.id)-logo.png"
        merchantLogo.downloadedFrom(link: imageLink)
        merchantLogo.contentMode = UIViewContentMode.scaleAspectFit
        merchantLogo.layer.masksToBounds = true
        merchantName.text = outlet.merchant.name
        offerName.text = offer.name
        offerSavings.text = "Savings: €" + offer.max_savings
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let validDate = formatter.date(from: offer.end_date)
        formatter.dateFormat = "dd MMM yyyy"
        let validDateString = formatter.string(from: validDate!)
        offerExpiry.text = "Valid Until " + validDateString
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRulesSegue" {
            guard let rulesOfUseViewController = segue.destination as? RulesOfUseViewController else {return}
            rulesOfUseViewController.previousVC = "blockedoffer"
        }
    }
    
    @IBAction func unwindToBlockedOfferViewController(_ segue: UIStoryboardSegue) {
        
    }

}

//
//  PurchaseHistoryTableViewCell.swift
//  Access Algarve
//
//  Created by Daniel Santos on 27/03/2018.
//  Copyright © 2018 Daniel Santos. All rights reserved.
//

import UIKit

class PurchaseHistoryTableViewCell: UITableViewCell {

    @IBOutlet var productImage: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productExpiry: UILabel!
    @IBOutlet weak var purchaseDate: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//
//  CartTableViewCell.swift
//  Access Algarve
//
//  Created by Daniel Santos on 31/03/2018.
//  Copyright © 2018 Daniel Santos. All rights reserved.
//

import UIKit

class CartTableViewCell: UITableViewCell {

    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productSubtitle: UILabel!
    @IBOutlet weak var productDescription: UILabel!
    @IBOutlet weak var purchaseButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

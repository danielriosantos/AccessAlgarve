//
//  ViewControllerTableViewCell.swift
//  Access Algarve Light
//
//  Created by Daniel Santos on 01/03/2018.
//  Copyright © 2018 Daniel Santos. All rights reserved.
//

import UIKit

class ViewControllerTableViewCell: UITableViewCell {
    
    @IBOutlet weak var voucherCompanyLogo: UIImageView!
    @IBOutlet weak var voucherOfferName: UILabel!
    @IBOutlet weak var voucherOfferType: UILabel!
    @IBOutlet weak var voucherLocation: UILabel!
    @IBOutlet weak var voucherEstimatedSavings: UILabel!
    @IBOutlet weak var voucherArrow: UIButton!
    @IBOutlet var voucherSelected: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.voucherSelected?.isOn = false
    }

}

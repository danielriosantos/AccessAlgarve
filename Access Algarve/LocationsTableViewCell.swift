//
//  LocationsTableViewCell.swift
//  Access Algarve Light
//
//  Created by Daniel Santos on 20/03/2018.
//  Copyright © 2018 Daniel Santos. All rights reserved.
//

import UIKit

class LocationsTableViewCell: UITableViewCell {

    @IBOutlet var location: UILabel!
    @IBOutlet var status: UISwitch!
    
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
        self.status.isOn = true
    }

}

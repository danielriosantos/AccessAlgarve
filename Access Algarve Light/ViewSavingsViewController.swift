//
//  ViewSavingsViewController.swift
//  Access Algarve Light
//
//  Created by Daniel Santos on 22/03/2018.
//  Copyright © 2018 Daniel Santos. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class ViewSavingsViewController: UIViewController {

    @IBOutlet var totalSavings: UILabel!
    var savingsamount: Double!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        totalSavings.text = "€" + String(Int(savingsamount.rounded(.up)))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }

}
